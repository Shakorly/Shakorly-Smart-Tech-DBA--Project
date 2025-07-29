-- Script: 1 set Recovery mode model
--Purpose: Put the database in FULL recovery model to allow for log backups

ALTER DATABASE [model] SET RECOVERY FULL;
GO