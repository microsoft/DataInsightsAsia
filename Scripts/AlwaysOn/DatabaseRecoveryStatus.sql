--
-- Author:  Matt Lavery
-- Date:    16/10/2018
-- Purpose: Report the current status of the Database Recovery command
--
--  SQL Version:   SQL 2012 (+ greater)
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
-- When         Who         What
--------------------------------------------------------------------------------------------
--


-- option 1 from the executing requests
SELECT er.[session_id]
    , er.[command]
    , CONVERT(NUMERIC(6,2),er.percent_complete) AS [percent_complete]
    , CONVERT(VARCHAR(20),DATEADD(ms,er.estimated_completion_time,GetDate()),20) AS [eta_completion_time]
    , CONVERT(NUMERIC(10,2),er.total_elapsed_time/1000.0/60.0) AS [elapsed_min]
    , CONVERT(NUMERIC(10,2),er.estimated_completion_time/1000.0/60.0) AS [eta_min]
    , CONVERT(NUMERIC(10,2),er.estimated_completion_time/1000.0/60.0/60.0) AS [eta_hours]
    , SUBSTRING(st.[text], qs.statement_start_offset/2, (
                CASE  
                    WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), st.[text])) * 2  
                    ELSE qs.statement_end_offset
                END - qs.statement_start_offset) / 2  
            ) AS [query_text]
FROM sys.dm_exec_requests er 
CROSS APPLY sys.dm_exec_sql_text(er.[sql_handle]) AS st 
WHERE er.[command] IN ('DB Startup') 

-- option 2 raw entries from the errorlog
exec sp_readerrorlog 0, 1, 'Recovery', 'database'
