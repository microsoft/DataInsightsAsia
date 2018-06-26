--
--  Author:        Matt Lavery
--  Date:          25/05/2016
--  Purpose:       Provides a smart / automated approach to database restores
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  25/05/2016  0.1.1       mlavery     Dynamically detect the database files and fix orphaned users
--  -----------------------------------------------------------------
--

-- Set this to 1 if you want the SQL statements to be run
DECLARE @ExecuteSQL BIT = 0;

-- variables we need
DECLARE @dbName SYSNAME;
DECLARE @tsqlFileListCmd VARCHAR(500);
DECLARE @tsqlRestoreCmd VARCHAR(500);
Declare @fileName varChar(255)
Declare @backupDir varchar(255)
Declare @dataDir varchar(255)
Declare @logDir varchar(255)
declare @logicalName varchar(255)
declare @physicalName varchar(500)
declare @fileType varchar(5)

----------------------------------------------------
-- Configuration
----------------------------------------------------
set @fileName = null;
set @backupDir = 'C:\temp\';
set @dbName = 'restoreTestOrphans';
set @dataDir = 'C:\SQLSERVER\SQLSERVER2014\DATA\';
Set @logDir = @logDir;


----------------------------------------------------
-- Get the most recent .BAK file (if not already set)
----------------------------------------------------
IF (null = @fileName)
BEGIN
	-- Create the temp table to hold the list of restore files
	IF OBJECT_ID('tempdb..#tblFileList') IS NOT NULL DROP TABLE #tblFileList
	CREATE TABLE #tblFileList (
		FileName VARCHAR(255),
		DepthFlag INT,
		FileFlag INT
	)
	-- Populate our temp table with the list of files and folders in the backup folder
	INSERT INTO #tblFileList EXEC xp_dirtree @backupDir,0,1
	-- Get the latest backup file name
	SELECT TOP 1 @fileName = @backupDir + fileName FROM #tblFileList WHERE FileName LIKE '%.BAK' ORDER BY FileName DESC;
	IF (null = @fileName)
		RAISERROR ('No backups found.', -- Message text.  
				16, -- Severity.  
				1 -- State.  
				);
END

----------------------------------------------------
-- Restore the backup file found
----------------------------------------------------

-- Debug info
PRINT '------------------------------';
PRINT 'Restoring file: ' + @fileName;
PRINT '------------------------------';

-- Make sure we have exclusive access to the database
IF (@ExecuteSQL = 1)
BEGIN
	EXEC ('ALTER DATABASE [' + @dbName + ']	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');
END

-- temp table to hold file info from backup media
IF EXISTS(SELECT * FROM [tempdb].[sys].[tables] WHERE name LIKE '#tblBackupMediaFileList%') DROP TABLE #tblBackupMediaFileList
CREATE TABLE #tblBackupMediaFileList (
	LogicalName VARCHAR(255),
	PhysicalName VARCHAR(500),
	Type VARCHAR(1),
	FileGroupName VARCHAR(64),
	Size DECIMAL(20,0),
	MaxSize DECIMAL(25,0),
	FileID bigint, 
	CreateLSN DECIMAL(25,0),
	DropLSN DECIMAL(25,0),
	UniqueID UNIQUEIDENTIFIER,
	ReadOnlyLSN DECIMAL(25,0),
	ReadWriteLSN DECIMAL(25,0),
	BackupSizeInBytes DECIMAL(25,0),
	SourceBlockSize INT,
	FileGroupId INT,
	LogGroupGUID UNIQUEIDENTIFIER,
	differentialbaseLSN DECIMAL(25,0),
	differentialbaseGUID UNIQUEIDENTIFIER,
	isreadonly BIT,
	ispresent BIT,
	TDEThumbprint varchar(255)
)


-- Get the list of files in the backup media
SET @tsqlFileListCmd = 'RESTORE FILELISTONLY FROM DISK = ''' + @fileName + ''' ';
INSERT INTO #tblBackupMediaFileList
EXEC (@tsqlFileListCmd)

-- Build the base of the restore statement
SET @tsqlRestoreCmd = 'RESTORE DATABASE [' + @dbName + ']
	FROM DISK = ''' + @fileName + '''
	WITH RECOVERY, ' 

-- Dynamically add the logical files from the restore media
DECLARE curFileList CURSOR FOR
SELECT [LogicalName], [PhysicalName], [Type] FROM #tblBackupMediaFileList ORDER BY [Type]
OPEN curFileList
FETCH NEXT FROM curFileList INTO @logicalName, @physicalName, @fileType
WHILE @@FETCH_STATUS = 0
BEGIN
	IF (@fileType = 'LOG')
	BEGIN
		SET @tsqlRestoreCmd = @tsqlRestoreCmd + ' MOVE N''' + @logicalName + ''' TO N''' + @logDir + @logicalName + '.ldf'','
	END
	ELSE
	BEGIN
		IF (SUBSTRING(@physicalName,LEN(@physicalName)-4,0) = '.mdf')
		BEGIN
			SET @tsqlRestoreCmd = @tsqlRestoreCmd + ' MOVE N''' + @logicalName + ''' TO N''' + @dataDir + @logicalName + '.mdf'','
		END
		ELSE
		BEGIN
			SET @tsqlRestoreCmd = @tsqlRestoreCmd + ' MOVE N''' + @logicalName + ''' TO N''' + @dataDir + @logicalName + '.mdf'','
		END
	END

	-- fetch the next record
	FETCH NEXT FROM curFileList INTO @logicalName, @physicalName, @fileType
END
CLOSE curFileList
DEALLOCATE curFileList

-- Finish off the restore statement
SET @tsqlRestoreCmd = @tsqlRestoreCmd + ' REPLACE, STATS = 10';

-- Output the restore command for documentation/troubleshooting
PRINT @tsqlRestoreCmd;

-- Restore the database if configured to do so
IF (@ExecuteSQL = 1)
BEGIN
	-- Run the restore command as built above
	EXEC (@tsqlRestoreCmd)

	-- Let access to the database resume
	EXEC ('ALTER DATABASE [' + @dbName + '] SET MULTI_USER WITH ROLLBACK IMMEDIATE;');
	EXEC ('ALTER DATABASE [' + @dbName + '] SET RECOVERY SIMPLE');
END


----------------------------------------------------
-- Fix orphan users
-- Reference https://msdn.microsoft.com/en-AU/library/ms175475.aspx
-- This could be added as second setup
----------------------------------------------------
-- Variables we need
DECLARE @typeDesc varchar(20),
	@sid varbinary(85),
	@userName varchar(200),
	@tsqlFixOrphansCmd varchar(500)
-- Create the temp table to hold the orphan users
IF EXISTS(SELECT * FROM tempdb.sys.tables WHERE name LIKE '#tblOrphans%') DROP TABLE #tblOrphans
CREATE TABLE #tblOrphans
(
	type_desc VARCHAR(20),
	SID VARBINARY(85),
	user_name VARCHAR(200)
)
SET @tsqlFixOrphansCmd = 'USE ' + @dbName + '
		SELECT dp.type_desc, dp.SID, dp.name AS user_name
		FROM sys.database_principals AS dp
		LEFT JOIN sys.server_principals AS sp
			ON dp.SID = sp.SID
		WHERE sp.SID IS NULL
			AND authentication_type_desc = ''INSTANCE'' ';
INSERT INTO #tblOrphans
EXEC (@tsqlFixOrphansCmd)

DECLARE curOrphanUsers cursor for
SELECT * FROM #tblOrphans
OPEN curOrphanUsers
FETCH NEXT FROM curOrphanUsers INTO @typeDesc, @sid, @userName
WHILE @@FETCH_STATUS = 0
BEGIN	
	IF EXISTS(SELECT name FROM master.sys.syslogins WHERE name = @userName)
	BEGIN
		SET @tsqlFixOrphansCmd = 'USE ' + @dbName + '; ALTER USER [' + @userName + '] WITH Login = ' + @userName + ';';
		
		-- Output the command for documentation/troubleshooting
		PRINT @tsqlFixOrphansCmd

		-- Run the command as built above
		IF (@ExecuteSQL = 1)
		BEGIN
			EXEC (@tsqlFixOrphansCmd)
		END
	END
	ELSE
	BEGIN
		-- Output for documentation/troubleshooting
		PRINT 'No Login found for user ' + @userName
	END
	FETCH NEXT FROM curOrphanUsers INTO @typeDesc, @sid, @userName
END
CLOSE curOrphanUsers
DEALLOCATE curOrphanUsers

