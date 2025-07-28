-- SCRIPT: 5_Get-SecurityPrincipals.sql
-- PURPOSE: Lists all logins and checks for high-privilege server roles.

SELECT
    p.name AS LoginName,
    p.type_desc AS LoginType,
    p.is_disabled,
    CASE
        WHEN IS_SRVROLEMEMBER('sysadmin', p.name) = 1 THEN 'YES'
        ELSE 'NO'
    END AS IsSysAdmin
FROM sys.server_principals p
WHERE p.type IN ('U', 'G', 'S') -- Windows, Group, SQL Logins
ORDER BY p.name;