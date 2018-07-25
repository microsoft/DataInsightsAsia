--
--  Author:        Matt Lavery
--  Date:          25/07/2018
--  Purpose:       Drop the session when you no longer need it
--  Reference:     https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-code-ring-buffer
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

-- follow the steps in 04.DisableRingBufferAndXEvent.sql first

-- drop the event (if required)
DROP EVENT SESSION [error_trap_xel]
    ON DATABASE;
GO
