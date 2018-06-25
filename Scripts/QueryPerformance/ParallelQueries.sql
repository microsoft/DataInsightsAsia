--
--  Author:        Matt Lavery
--  Date:          22/04/2013
--  Purpose:       This script will identify queries which are using parallel execution plans
--  SQL Version:   SQL 2005 and greater
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  22/04/2013  0.1.1       mlavery     Initial Coding
--  -----------------------------------------------------------------
--

-- Queries using Parallelism - TOP 20 by worker time
SELECT TOP 20
	qs.*
	, qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qp.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
						max(//p:RelOp/@Parallel)', 'float') > 0
ORDER BY qs.total_worker_time DESC

