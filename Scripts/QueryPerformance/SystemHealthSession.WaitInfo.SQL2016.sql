/*********************************************************************************************
Written By: Matt Lavery
Date:		09/06/2016
Purpose:	This script is a modified version for SQL 2016 schema from the script by 
            Amit Banerjee @ https://troubleshootingsql.com/2011/09/23/system-health-session-part-2/
SQL Version: SQL 2016 (+ greater)
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