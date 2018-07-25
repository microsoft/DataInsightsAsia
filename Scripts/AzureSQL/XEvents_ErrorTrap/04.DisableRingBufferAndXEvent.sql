--
--  Author:        Matt Lavery
--  Date:          25/07/2018
--  Purpose:       Disables the session to free up resources
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

-- Stop the session
ALTER EVENT SESSION [error_trap_xel]
    ON DATABASE
    STATE = STOP;
GO

-- Remove the ring buffer to free those resources
ALTER EVENT SESSION [error_trap_xel]
    ON DATABASE
    DROP TARGET package0.ring_buffer;
GO

-- drop the event (if required)
DROP EVENT SESSION [error_trap_xel]
    ON DATABASE;
GO
