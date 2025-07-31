-- SCRIPT: 3_Test-Severity-16-Alert.sql
-- This command generates a user-defined error with severity 16.
RAISERROR ('This is a test of the severity 16 alarm system.', 16, 1);