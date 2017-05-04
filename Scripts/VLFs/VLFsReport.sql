/*********************************************************************************************
Written By: Matt Lavery
Date:		22/04/2013
Purpose:	This script will loop through the databases and output the details of 
			the lof file to help with identifying issues with high number of VLFs
SQL Version: SQL 2005 and greater
SQLRAP:		Performance \ SQL Performance

Changes:
Who		When		What


Disclaimer:
This Sample Code is provided for the purpose of illustration only and is not intended to be 
used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED 
"AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant 
You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and 
distribute the object code form of the Sample Code, provided that You agree: (i) to not use 
Our name, logo, or trademarks to market Your software product in which the Sample Code is 
embedded; (ii) to include a valid copyright notice on Your software product in which the 
Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our 
suppliers from and against any claims or lawsuits, including attorneys� fees, that arise 
or result from the use or distribution of the Sample Code.
*********************************************************************************************/


SET NOCOUNT ON;

/* declare variables required */
DECLARE @DatabaseId INT;
DECLARE @TSQL varchar(MAX);
DECLARE cur_DBs CURSOR FOR
	SELECT database_id FROM sys.databases;
OPEN cur_DBs;
FETCH NEXT FROM cur_DBs INTO @DatabaseId

--These table variables will be used to store the data
DECLARE @tblAllDBs Table (DBName sysname
	, FileId INT
	, FileSize BIGINT
	, StartOffset BIGINT
	, FSeqNo INT
	, Status TinyInt
	, Parity INT
	, CreateLSN NUMERIC(25,0)
)
IF  '11' = substring(convert(char(12),serverproperty('productversion')), 1, 2)
BEGIN
	DECLARE @tblVLFs2012 Table (RecoveryUnitId BIGINT
		, FileId INT
		, FileSize BIGINT
		, StartOffset BIGINT
		, FSeqNo INT
		, Status TinyInt
		, Parity INT
		, CreateLSN NUMERIC(25,0)
	);
END
ELSE
BEGIN
	DECLARE @tblVLFs Table (
		FileId INT
		, FileSize BIGINT
		, StartOffset BIGINT
		, FSeqNo INT
		, Status TinyInt
		, Parity INT
		, CreateLSN NUMERIC(25,0)
	);
END

--loop through each database and get the info
WHILE @@FETCH_STATUS = 0
BEGIN
	
	PRINT 'DB: ' + CONVERT(varchar(200), DB_NAME(@DatabaseId));
	SET @TSQL = 'dbcc loginfo('+CONVERT(varchar(12), @DatabaseId)+');';

	IF  '11' = substring(convert(char(12),serverproperty('productversion')), 1, 2)
	BEGIN
		DELETE FROM @tblVLFs2012;
		INSERT INTO @tblVLFs2012
		EXEC(@TSQL);
		INSERT INTO @tblAllDBs 
		SELECT DB_NAME(@DatabaseId)
			, FileId
			, FileSize
			, StartOffset
			, FSeqNo
			, Status
			, Parity
			, CreateLSN 
		FROM @tblVLFs2012;
	END
	ELSE
	BEGIN
		DELETE FROM @tblVLFs;
		INSERT INTO @tblVLFs 
		EXEC(@TSQL);
		INSERT INTO @tblAllDBs 
		SELECT DB_NAME(@DatabaseId)
			, FileId
			, FileSize
			, StartOffset
			, FSeqNo
			, Status
			, Parity
			, CreateLSN 
		FROM @tblVLFs;
	END

	FETCH NEXT FROM cur_DBs INTO @DatabaseId
END
CLOSE cur_DBs;
DEALLOCATE cur_DBs;

--just for formating if output to Text
PRINT '';
PRINT '';
PRINT '';

--Return the data based on what we have found
SELECT a.DBName
	, COUNT(a.FileId) AS [TotalVLFs]
	, MAX(b.[ActiveVLFs]) AS [ActiveVLFs]
	, (SUM(a.FileSize) / COUNT(a.FileId) / 1024) AS [AvgFileSizeKb]
FROM @tblAllDBs a
INNER JOIN (
	SELECT DBName
		, COUNT(FileId) [ActiveVLFs]
	FROM @tblAllDBs 
	WHERE Status = 2
	GROUP BY DBName
	) b
	ON b.DBName = a.DBName
GROUP BY a.DBName
ORDER BY TotalVLFs DESC;


SET NOCOUNT OFF;


--SELECT DB_ID('MattLTest')
--dbcc loginfo(6)
