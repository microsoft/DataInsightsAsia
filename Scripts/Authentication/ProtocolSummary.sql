--
--  Author:        Matt Lavery
--  Date:          10/04/2018
--  Purpose:       Reports a summary of network protocols used by current connections
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  10/04/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

USE master
GO
-- network protocols
SELECT net_transport, COUNT(*) as [count]
FROM sys.dm_exec_connections
GROUP BY net_transport
