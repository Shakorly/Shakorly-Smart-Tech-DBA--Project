--SCRIPT: 1 Enable Database Mail

sp_configure 'SHow advanced option', 1;
GO

RECONFIGURE;
GO

sp_configure 'Database Mail XPs'
GO

RECONFIGURE
GO