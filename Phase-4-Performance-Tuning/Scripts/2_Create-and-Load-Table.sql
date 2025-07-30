USE ShakorlySmartTech

-- SCRIPT: 2_Create-and-Load-Table.sql
-- PURPOSE: Creates a sample table with no indexes to simulate a performance problem.

CREATE TABLE dbo.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(100),
    Department NVARCHAR(50),
    HireDate DATE
);
GO

-- Insert 50,000 rows of sample data. This may take a moment.
INSERT INTO dbo.Employees (EmployeeName, Department, HireDate)
SELECT
    'Employee_' + CAST(ROW_NUMBER() OVER (ORDER BY a.object_id) AS VARCHAR(10)),
    'Sales',
    GETDATE() - (ROW_NUMBER() OVER (ORDER BY a.object_id) % 1000)
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;
GO