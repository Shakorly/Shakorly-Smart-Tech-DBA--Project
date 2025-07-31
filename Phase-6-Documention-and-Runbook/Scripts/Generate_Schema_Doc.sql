-- SCRIPT: Generate_Schema_Doc.sql
-- PURPOSE: Creates a simple data dictionary for a given database.
-- INSTRUCTIONS: Run this script in the context of the database you want to document (e.g., InnovatechPerformanceLab).

USE ShakorlySmartTech

SELECT
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM
    sys.tables AS t
JOIN
    sys.columns AS c ON t.object_id = c.object_id
JOIN
    sys.types AS ty ON c.user_type_id = ty.user_type_id
WHERE
    t.is_ms_shipped = 0 -- Exclude system tables
ORDER BY
    t.name,
    c.column_id;	


