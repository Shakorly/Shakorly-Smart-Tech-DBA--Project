-- SCRIPT: 3_SIMULATE_DISASTER.sql
-- PURPOSE: Deletes the database to test our recovery ability.
-- In a real environment, you would take the DB offline first.
USE practiceDB;
GO
DROP DATABASE practiceDB;
GO