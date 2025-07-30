/*
Missing Index Details from SQLQuery7.sql - SHAKORYSMARTTEC.ShakorlySmartTech (SHAKORYSMARTTEC\USER (74))
The Query Processor estimates that implementing the following index could improve the query cost by 99.924%.
*/

/*
USE [ShakorlySmartTech]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[Employees] ([EmployeeName])

GO
*/



CREATE NONCLUSTERED INDEX index_EmployeeName
ON [dbo].[Employees] ([EmployeeName])
INCLUDE ([Department],[HireDate])