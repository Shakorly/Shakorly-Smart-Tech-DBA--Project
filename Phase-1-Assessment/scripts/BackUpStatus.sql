-- SCRIPT: 4_Get-BackupStatus.sql
-- PURPOSE: Checks the last backup date for all databases. THIS IS A CRITICAL CHECK.

SELECT
   d.name AS DatabaseName,
   d.recovery_model_desc,
   ISNULL(CONVERT(varchar, MAX(b.backup_finish_date), 120), '*** NO BACKUP FOUND ***') AS LastBackupDate
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b ON d.name = b.database_name
WHERE d.database_id != 2 -- Exclude tempdb
GROUP BY d.name, d.recovery_model_desc
ORDER BY d.name;