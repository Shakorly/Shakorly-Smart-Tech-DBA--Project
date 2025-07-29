--Script: Manual first full backup
--Purpose: Create the initial full backup to start the backup chain

BACKUP DATABASE [MODEL]
TO DISK = 'C:\Users\USER\OneDrive\Documents\GitHub\Shakorly-Smart-Tech-DBA--Project\Phase-3-Backup-and-Recovery\Scripts\SQLBackups\model_full_initial.bak'
WITH COMPRESSION, STATS = 10;
GO