--
--  Author:        Matt Lavery
--  Date:          03/02/2017
--  Purpose:       Script to restore the Log Shipped databases during a failover
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  03/02/2017  0.1.1       mlavery     Initial Coding
--  -----------------------------------------------------------------
--

-- Set this to 1 if you want the SQL statements to be run
DECLARE @ExecuteSQL BIT = 0;


-- variables we need
DECLARE @dbName SYSNAME;
DECLARE @tsqlCmd VARCHAR(400);

-- create the cursor to hold the list of dbs
DECLARE curDbList cursor FOR
SELECT [primary_database]
FROM [msdb].[dbo].[log_shipping_secondary]
ORDER BY [primary_database]

-- loop over the list of databases
OPEN curDbList
FETCH NEXT FROM curDbList INTO @dbName
WHILE @@FETCH_STATUS = 0
BEGIN
	
	-- generate the TSQL statement to restore the log
	SET @tsqlCmd = 'RESTORE LOG '+@dbName;

	-- output the TSQL statement
	PRINT @tsqlCmd;
	PRINT 'GO';
	
	-- execute the statement if configured to do so
	IF (@ExecuteSQL = 1)
	BEGIN
		EXEC (@tsqlCmd);
	END
	
	-- fetch the next record
	FETCH NEXT FROM curDbList INTO @dbName
	
END -- cursor loop

-- clean up
CLOSE curDbList
DEALLOCATE curDbList


