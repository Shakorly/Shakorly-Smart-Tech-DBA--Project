
-- This command allows us to change advanced settings.

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO


-- This sets the 'max server memory (MB)' setting to our new value (e.g., 6144 MB).
-- !! CHANGE THIS VALUE based on your computer's RAM !!

EXEC sp_configure 'max server memory (MB)', 6144;
RECONFIGURE;
GO

EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO