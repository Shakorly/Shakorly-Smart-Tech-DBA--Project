-- SCRIPT: 4_Daily-Health-Check_v3.sql
-- PURPOSE: Checks critical server metrics and emails a formatted HTML report.
-- VERSION: 3.0 - Now compatible with older SQL Server versions (2008+).

-- =================================================================
-- 1. CONFIGURATION
-- =================================================================
DECLARE @recipients NVARCHAR(MAX) = 'talk2shakor@gmail.com'; -- <<<!!! CHANGE THIS TO YOUR EMAIL ADDRESS !!!>>>
DECLARE @subject NVARCHAR(255);
DECLARE @body NVARCHAR(MAX);
DECLARE @tableHTML NVARCHAR(MAX);

SET @subject = 'Daily Health Check for ' + @@SERVERNAME;
SET @body = N'<H1>Daily Health Check Report for ' + @@SERVERNAME + '</H1>' +
            N'Report Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 120) +
            N'<style type="text/css">' +
            N'body {font-family: Arial, sans-serif;}' +
            N'h2 {color: #333399;}' +
            N'table {border-collapse: collapse; width: 80%;}' +
            N'th, td {border: 1px solid #ddd; padding: 8px; text-align: left;}' +
            N'th {background-color: #f2f2f2;}' +
            N'.critical {color: red; font-weight: bold;}' +
            N'.ok {color: green;}' +
            N'</style>';

-- =================================================================
-- 2. CHECK FOR FAILED JOBS in the last 24 hours
-- =================================================================
SET @tableHTML = NULL;
SELECT @tableHTML =
    N'<h2>SQL Agent Job Status (Last 24 Hours)</h2>' +
    N'<table>' +
    N'<tr><th>Job Name</th><th>Run Status</th><th>Message</th><th>Run Datetime</th></tr>' +
    CAST((
        SELECT
            td = j.name, '',
            td = CASE h.run_status
                     WHEN 0 THEN '<span class="critical">Failed</span>'
                     WHEN 1 THEN 'Succeeded'
                     WHEN 2 THEN 'Retry'
                     WHEN 3 THEN 'Canceled'
                     WHEN 4 THEN 'In Progress'
                 END, '',
            td = h.message, '',
            td = msdb.dbo.agent_datetime(h.run_date, h.run_time)
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
        WHERE h.step_id = 0 -- Job Outcome
          AND h.run_date >= CONVERT(INT, FORMAT(GETDATE() - 1, 'yyyyMMdd'))
          AND h.run_status = 0 -- Only show failed jobs
        ORDER BY h.run_date, h.run_time
        FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX)) +
    N'</table>';

IF @tableHTML IS NOT NULL
    SET @body = @body + @tableHTML;
ELSE
    SET @body = @body + N'<h2>SQL Agent Job Status (Last 24 Hours)</h2><p class="ok">No failed jobs found.</p>';


-- =================================================================
-- 3. CHECK FOR DATABASES WITHOUT A RECENT FULL BACKUP (older than 8 days)
-- ** VERSION 2 - Compatible with older SQL versions by joining on name **
-- =================================================================
SET @tableHTML = NULL;
SELECT @tableHTML =
    N'<h2>Backup Status (Full Backups older than 8 days)</h2>' +
    N'<table>' +
    N'<tr><th>Database Name</th><th>Last Full Backup</th><th>Recovery Model</th></tr>' +
    CAST((
        SELECT
            td = d.name, '',
            td = ISNULL(CONVERT(VARCHAR(20), MAX(b.backup_finish_date), 120), '<span class="critical">NEVER</span>'), '',
            td = d.recovery_model_desc
        FROM sys.databases d
        LEFT JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'D' -- Full Backups
        WHERE d.name NOT IN ('tempdb')
        GROUP BY d.name, d.recovery_model_desc
        HAVING MAX(b.backup_finish_date) < GETDATE() - 8 OR MAX(b.backup_finish_date) IS NULL
        ORDER BY d.name
        FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX)) +
    N'</table>';

IF @tableHTML IS NOT NULL
    SET @body = @body + @tableHTML;
ELSE
    SET @body = @body + N'<h2>Backup Status</h2><p class="ok">All databases have a recent full backup.</p>';


-- =================================================================
-- 4. CHECK FOR LOW DISK SPACE
-- ** VERSION 2 - Compatible with older SQL versions using xp_fixeddrives **
-- =================================================================
IF OBJECT_ID('tempdb..#drives') IS NOT NULL DROP TABLE #drives;
CREATE TABLE #drives (
    drive CHAR(1),
    MB_free INT
);

INSERT INTO #drives EXEC xp_fixeddrives;

SET @tableHTML = NULL;
SELECT @tableHTML =
    N'<h2>Disk Space Status</h2>' +
    N'<table>' +
    N'<tr><th>Drive</th><th>Free Space (MB)</th></tr>' +
    CAST((
        SELECT
            td = d.drive, '',
            td = CASE
                     WHEN d.MB_free < 5120 -- Alert if less than 5 GB free
                     THEN '<span class="critical">' + CAST(d.MB_free AS VARCHAR(20)) + '</span>'
                     ELSE CAST(d.MB_free AS VARCHAR(20))
                 END
        FROM #drives d
        -- Optionally, only show drives below a certain threshold to reduce noise
        -- WHERE d.MB_free < 20480 -- e.g., only show drives with less than 20GB free
        ORDER BY d.drive
        FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX)) +
    N'</table>';

IF @tableHTML IS NOT NULL
    SET @body = @body + @tableHTML;
ELSE
    SET @body = @body + N'<h2>Disk Space Status</h2><p class="ok">All drives have sufficient free space.</p>';

DROP TABLE #drives;


-- =================================================================
-- 5. SEND THE EMAIL
-- =================================================================
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'DBA Alerts Profile', -- Use the profile we created in Task 5.1
    @recipients = @recipients,
    @subject = @subject,
    @body = @body,
    @body_format = 'HTML';