--
--  Author:        Matt Lavery
--  Date:          09/04/2018
--  Purpose:       Report the number of start up procs in each database
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  09/04/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

EXEC sp_MSforeachdb 'USE [?];
    SELECT DB_NAME() as [dbname], COUNT(*) as [numstartupprocs] FROM sys.procedures WHERE is_auto_executed = 1'
