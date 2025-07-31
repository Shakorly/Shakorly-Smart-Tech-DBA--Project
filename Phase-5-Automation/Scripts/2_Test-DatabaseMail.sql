-- SCRIPT: 2_Test-DatabaseMail.sql
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'DBA Alerts Profile',
    @recipients = 'talk2shakor@gmail.com',
    @subject = 'Test from SQL Server',
    @body = 'If you received this, Database Mail is working correctly!';