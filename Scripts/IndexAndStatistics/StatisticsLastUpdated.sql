/*********************************************************************************************
Written By: Matt Lavery
Date:		16/07/2013
Purpose:	Reports statistics which are needed to be updated

Changes:
Who			When		What
MLavery		16/07/2013	Initial Coding


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

SELECT DISTINCT SCHEMA_NAME(so.schema_id) AS 'SchemaName'
	, OBJECT_NAME(so.object_id) AS 'TableName'
	, so.object_id AS 'object_id'
	, CASE OBJECTPROPERTY(MAX(so.object_id), 'TableHasClustIndex') 
		WHEN 1 THEN 'Clustered' 
		WHEN 0 THEN 'Heap' 
		ELSE 'Indexed View' 
	END AS 'ClusteredHeap'
	, CASE objectproperty(max(so.object_id), 'TableHasClustIndex') 
		WHEN 0 THEN count(si.index_id) - 1 
		ELSE count(si.index_id) 
	END AS 'IndexCount'
	, MAX(d.ColumnCount) AS 'ColumnCount'
	, MAX(s.StatCount) AS 'StatCount'
	, MAX(dmv.rows) AS 'ApproximateRows'
	, MAX(dmv.rowmodctr) AS 'RowModCtr'
FROM sys.objects so (NOLOCK)
JOIN sys.indexes si (NOLOCK) ON so.object_id = si.object_id AND so.type in (N'U',N'V')
JOIN sysindexes dmv (NOLOCK) ON so.object_id = dmv.id AND si.index_id = dmv.indid
FULL OUTER JOIN (SELECT object_id, count(1) AS ColumnCount FROM sys.columns (NOLOCK) GROUP BY object_id) d ON d.object_id = so.object_id
FULL OUTER JOIN (SELECT object_id, count(1) AS StatCount FROM sys.stats (NOLOCK) GROUP BY object_id) s ON s.object_id = so.object_id
WHERE so.is_ms_shipped = 0
AND so.object_id not in (SELECT major_id FROM sys.extended_properties (NOLOCK) WHERE name = N'microsoft_database_tools_support')
AND indexproperty(so.object_id, si.name, 'IsStatistics') = 0
GROUP BY so.schema_id
	, so.object_id
	, (CASE objectproperty(si.object_id, 'TableHasClustIndex')
		WHEN 1 THEN 'Clustered'
		WHEN 0 THEN 'Heap'
		ELSE 'Indexed View'
	end)
HAVING ( MAX(dmv.rows) > 500 AND MAX(dmv.rowmodctr) > (max(dmv.rows)*0.2 + 500 ))
ORDER BY 1,2

