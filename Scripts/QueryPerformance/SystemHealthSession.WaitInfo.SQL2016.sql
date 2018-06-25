--
--  Author:        Matt Lavery
--  Date:          09/06/2016
--  Purpose:       This script is a modified version for SQL 2016 schema from the script by 
--                 Amit Banerjee @ https://troubleshootingsql.com/2011/09/23/system-health-session-part-2/
--  SQL Version:   SQL 2016 (+ greater)
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  09/06/2016  0.1.1       mlavery     Initial Coding
--  -----------------------------------------------------------------
--

-- Updated for SQL 2016 format

SELECT CAST(xet.target_data AS XML) AS XMLDATA
 
INTO #SystemHealthSessionData
 
FROM sys.dm_xe_session_targets xet
 
JOIN sys.dm_xe_sessions xe
 
ON (xe.address = xet.event_session_address)
 
WHERE xe.name = 'system_health'
 
;WITH CTE_HealthSession (EventXML) AS
 
(
 
SELECT C.query('.') EventXML
 
FROM #SystemHealthSessionData a
 
CROSS APPLY a.XMLDATA.nodes('/RingBufferTarget/event') as T(C)
 
WHERE C.query('.').value('(/event/@name)[1]', 'varchar(255)') in ('wait_info','wait_info_external')
 
)
 
SELECT
 
EventXML.value('(/event/@timestamp)[1]', 'datetime') as EventTime,
 
EventXML.value('(/event/data/text)[1]', 'varchar(50)') as WaitType,
 
EventXML.value('(/event/data/value)[3]', 'int') as Duration,
 
EventXML.value('(/event/action/value)[2]', 'varchar(10)') as Session_ID,
 
EventXML.value('(/event/action/value)[1]', 'varchar(max)') as sql_text

FROM CTE_HealthSession

ORDER BY EventTime DESC
 
DROP TABLE #SystemHealthSessionData