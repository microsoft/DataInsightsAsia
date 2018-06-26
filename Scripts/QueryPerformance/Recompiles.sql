--
--  Author:        Matt Lavery
--  Date:          15/07/2013
--  Purpose:       Returns queries with higher plan generations than executions to assist with
--                 identifying queries with high recompiles
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  15/07/2013  0.1.1       mlavery     Initial Coding
--  -----------------------------------------------------------------
--

SELECT qs.last_execution_time
	, qs.execution_count
	, qs.plan_generation_num
	, cp.usecounts as [QueryPlan_UseCounts]
	, cp.cacheobjtype as [CacheObjType]
	, cp.objtype as [ObjType]
	--, qs.statement_start_offset
	--, qs.statement_end_offset
	, st.text as [QueryText]
	, SUBSTRING(st.text, qs.statement_start_offset/2,
        (CASE WHEN qs.statement_end_offset = -1
        THEN LEN (CONVERT (nvarchar(max), st.text)) * 2
        ELSE qs.statement_end_offset END -
        qs.statement_start_offset)/2) as [StmtText]
	, qp.query_plan as [QueryPlan]
FROM sys.dm_exec_query_stats qs
INNER JOIN sys.dm_exec_cached_plans cp ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
WHERE st.text NOT LIKE N'%sys.dm_%'
AND qs.plan_generation_num > qs.execution_count
--AND st.text LIKE N'%ProcCacheTest%'
ORDER BY qs.plan_generation_num DESC
	, qs.execution_count DESC
	, qs.last_execution_time DESC;