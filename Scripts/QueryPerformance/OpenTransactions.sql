--
--  Author:        Matt Lavery
--  Date:          18/06/2018
--  Purpose:       Reports the open transactions in the instance
--                 Use the transaction_begin_time to determine if active (e.g. looping and batch processing)
--  Reference:     TBA
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  18/06/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--


SELECT er.session_id
	, er.request_id
	, er.start_time
	, er.status
	, er.command
	, er.database_id
	, er.user_id
	--, er.connection_id
	, er.blocking_session_id
	, er.wait_type
	, er.wait_time
	, er.last_wait_type
	, er.wait_resource
	, er.open_transaction_count
    --, er.transaction_id
	, tat.name [transaction_name]
	, tat.transaction_begin_time
	, er.open_resultset_count
	, er.percent_complete
	, er.cpu_time
	, er.total_elapsed_time
	, er.reads
	, er.writes
	, er.logical_reads
	, st.text [batch_sql_text]
	, SUBSTRING(st.[text], er.statement_start_offset/2, ( 
                CASE  
                    WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), st.[text])) * 2  
                    ELSE er.statement_end_offset                  
				END - er.statement_start_offset)/2  
            ) AS stmt_sql_text 
FROM sys.dm_exec_requests er
LEFT JOIN sys.dm_tran_active_transactions tat 
	ON tat.transaction_id = er.transaction_id
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE er.open_transaction_count > 0
ORDER BY cpu_time desc, start_time

-- To report only the active transactions you can use
--DBCC opentran