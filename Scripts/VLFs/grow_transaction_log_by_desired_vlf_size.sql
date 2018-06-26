--
--  Author:        Ben Harding
--  Date:          14/05/2018
--  Purpose:	   Will produce TSQL commands to grow a transaction log to a desired size with  
--                 a desired VLF size. 
--                 Supports change to VLF creation logic introduced in SQL Server 2014.
--  SQL Version:   SQL 2005 and greater
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  14/05/2018  0.1.0       behardin    Intitial release
--  -----------------------------------------------------------------
--

SET NOCOUNT ON
GO

DECLARE @desired_size_mb		BIGINT
DECLARE @desired_vlf_size_mb	INT
DECLARE @growth_amount_mb		BIGINT
DECLARE @growth_amount_VLF		INT
DECLARE @current_VLFs			BIGINT
DECLARE @current_size			BIGINT
DECLARE @database_name			NVARCHAR(128)
DECLARE @logical_log_filename	NVARCHAR(128)

SET @desired_size_mb = 20480
SET @desired_vlf_size_mb = 512
SET @current_VLFs = 16
SET @current_size = 256
SET @database_name = 'xyz'
SET @logical_log_filename = 'xyz_log'

SELECT
	@current_size			AS current_size
	, @current_VLFs			AS current_VLFS
	, @growth_amount_mb		AS growth_amount_mb
	, @growth_amount_VLF	AS growth_amount_vlf

WHILE @desired_size_mb > @current_size
BEGIN
	IF @desired_vlf_size_mb > (@current_size/8)
	BEGIN
		SET @growth_amount_VLF = CASE WHEN @desired_vlf_size_mb <= 64 THEN 4 WHEN @desired_vlf_size_mb <= 1024 THEN 8 WHEN @desired_vlf_size_mb > 1024 THEN 16 END
		SET @growth_amount_mb = @desired_vlf_size_mb*@growth_amount_VLF
	END
	ELSE
	BEGIN
		SET @growth_amount_VLF = 1
		SET @growth_amount_mb = @desired_vlf_size_mb
	END

	SET @current_VLFs = @current_VLFs + @growth_amount_VLF
	SET @current_size = @current_size + @growth_amount_mb

	SELECT
		@current_size			AS current_size
		, @current_VLFs			AS current_VLFS
		, @growth_amount_mb		AS growth_amount_mb
		, @growth_amount_VLF	AS growth_amount_vlf

	PRINT N'ALTER DATABASE [' + @database_name + '] MODIFY FILE (NAME = N''' + @logical_log_filename + ''', SIZE = ' + CAST(@current_size AS NVARCHAR(128)) + N'MB)' + NCHAR(13) + N'GO'
END


