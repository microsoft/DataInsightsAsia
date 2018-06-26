--
--  Author:        Matt Lavery
--  Date:          10/04/2018
--  Purpose:       Reports a remote connections using NTLM
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
SELECT session_id
	, connect_time
	, net_transport
	, protocol_type
	, encrypt_option
	, auth_scheme
	, node_affinity
	, num_reads
	, num_writes
	, last_read
	, last_write
	, client_net_address
FROM sys.dm_exec_connections
WHERE auth_scheme  = 'NTLM'
AND net_transport <> 'Shared Memory'