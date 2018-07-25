--
--  Author:        Matt Lavery
--  Date:          25/07/2018
--  Purpose:       Creates a XEL session to collect errors in SQL Database
--  Reference:     https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-db-diff-from-svr
--                 https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-code-ring-buffer
--                 http://sqlblog.com/blogs/davide_mauri/archive/2013/03/17/trapping-sql-server-errors-with-extended-events.aspx
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--
--  -----------------------------------------------------------------
--

-- Create the sssion
CREATE EVENT SESSION [error_trap_xel] ON DATABASE 
ADD EVENT sqlserver.error_reported 
( 
    ACTION    (
        package0.event_sequence,
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_id,
        sqlserver.database_name,
        sqlserver.plan_handle,
        sqlserver.query_hash,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.tsql_stack,
        sqlserver.username)
    WHERE (
        [severity] > 10
    ) 
) 
ADD TARGET package0.ring_buffer
    (SET
        max_memory = 500   -- Units of KB.
    )
WITH 
    (        
        STARTUP_STATE=OFF 
    ) 
GO

-- Enable the session at startup
ALTER EVENT SESSION [error_trap_xel] ON DATABASE 
STATE = START; 
GO
