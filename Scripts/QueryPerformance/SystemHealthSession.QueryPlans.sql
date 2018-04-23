--
--  Author:        Ben Harding
--  Date:          20/04/2018
--  Purpose:       Get the query plans from the System Health Session XEL
--  Reference:     https://www.sqlskills.com/blogs/jonathan/extended-events-ring_buffer/
--                 https://www.mssqltips.com/sqlservertip/4210/extracting-showplan-xml-from-sql-server-extended-events/
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  23/04/2018  0.1.1       mlavery     Added code to support both Azure SQL and SQL Server
--  -----------------------------------------------------------------
--


SET NOCOUNT ON
GO

-- check if we are running on Azure PaaS
DECLARE @isAzurePaaS BIT;
IF ((SELECT @@Version) LIKE 'Microsoft SQL Azure%')
    SET @isAzurePaaS = 1;
ELSE
    SET @isAzurePaaS = 0;


DROP TABLE IF EXISTS #tmp
DECLARE @target_data XML;


-- Get the target data based on the host environment
if (@isAzurePaaS = 1)
BEGIN
    -- Azure SQL
    SELECT 
        @target_data = CAST(target_data AS XML)
    FROM 
        sys.dm_xe_database_sessions AS s 
        INNER JOIN sys.dm_xe_database_session_targets AS t 
        ON t.event_session_address = s.address
    WHERE 
        s.name = N'GetExecutionPlan';
END
ELSE
BEGIN
    -- SQL Server
    SELECT 
        @target_data = CAST(target_data AS XML)
    FROM 
        sys.dm_xe_sessions AS s 
        INNER JOIN sys.dm_xe_session_targets AS t 
        ON t.event_session_address = s.address
    WHERE 
        s.name = N'SQL_Activity';
END


SELECT
    n.query('.') AS event_data
INTO 
       #tmp
FROM 
       @target_data.nodes('RingBufferTarget/event') AS q(n);

SELECT 
      t.event_data.value(N'(/event/@timestamp)[1]', N'datetime') AS event_time
       , whole_xml   = t.event_data.query('.')
FROM 
       #tmp AS t;

SELECT 
      t.event_data.value(N'(/event/@timestamp)[1]', N'datetime') AS event_time
       , t.event_data.value('(/event/data[@name="duration"]/value)[1]', 'bigint') as duration
       , t.event_data.value(N'(/event/action[@name="sql_text"]/value)[1]', N'nvarchar(max)') AS sql_text
       , z.xml_fragment.query('.') AS xml_plan
FROM 
       #tmp AS t
       CROSS APPLY t.event_data.nodes(N'/event/data[@name="showplan_xml"]/value/*') AS z(xml_fragment);

GO

SET NOCOUNT OFF

GO