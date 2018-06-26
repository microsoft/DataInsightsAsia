--
--  Author:        Matt Lavery
--  Date:          22/04/2013
--  Purpose:	   This script will loop through the databases and output the details of 
--                 the lof file to help with identifying issues with high number of VLFs
--  SQL Version:   SQL 2005 and greater
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  06/02/2018  0.1.1       mlavery     Minor logic changes
--  -----------------------------------------------------------------
--

SET NOCOUNT ON;

-- declare variables required
DECLARE @majorVer SMALLINT, @minorVer SMALLINT, @build SMALLINT
DECLARE @DatabaseId INT;
DECLARE @TSQL varchar(MAX);
DECLARE cur_DBs CURSOR FOR
	SELECT database_id FROM sys.databases;
OPEN cur_DBs;
FETCH NEXT FROM cur_DBs INTO @DatabaseId

-- Get the version
SELECT @majorVer = (@@microsoftversion / 0x1000000) & 0xff, @minorVer = (@@microsoftversion / 0x10000) & 0xff, @build = @@microsoftversion & 0xffff

-- These table variables will be used to store the data
DECLARE @tblAllDBs Table (DBName sysname
	, FileId INT
	, FileSize BIGINT
	, StartOffset BIGINT
	, FSeqNo INT
	, Status TinyInt
	, Parity INT
	, CreateLSN NUMERIC(25,0)
)
IF ( @majorVer >= 11 )
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

	IF ( @majorVer >= 11 )
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

