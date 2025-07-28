SELECT @@version

SELECT name, description, value, value_in_use
FROM sys.configurations
ORDER BY name

SELECT @@VERSION AS SQLServerVersion;

SELECT 
	cpu_count,
	hyperthread_ratio,
	physical_memory_kb, 
	committed_kb
FROM
	sys.dm_os_sys_info;