--
--  Author:        Matt Lavery
--  Date:          25/07/2018
--  Purpose:       Restart / Re-enable the session
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

-- Remove the ring buffer to free those resources
ALTER EVENT SESSION [error_trap_xel]
    ON DATABASE
    ADD TARGET package0.ring_buffer (SET
        max_memory = 500   -- Units of KB.
    );
GO

-- Start the session
ALTER EVENT SESSION [error_trap_xel]
    ON DATABASE
    STATE = START;
GO
