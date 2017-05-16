/*********************************************************************************************
Written By: Matt Lavery
Date:		15/07/2013
Purpose:	Returns queries with higher plan generations than executions to assist with
			identifying queries with high recompiles

Changes:
Who			When		What
MLavery		15/07/2013	Initial Coding


Disclaimer:
This Sample Code is provided for the purpose of illustration only and is not intended to be 
used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED 
"AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant 
You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and 
distribute the object code form of the Sample Code, provided that You agree: (i) to not use 
Our name, logo, or trademarks to market Your software product in which the Sample Code is 
embedded; (ii) to include a valid copyright notice on Your software product in which the 
Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our 
suppliers from and against any claims or lawsuits, including attorneys� fees, that arise 
or result from the use or distribution of the Sample Code.
*********************************************************************************************/

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