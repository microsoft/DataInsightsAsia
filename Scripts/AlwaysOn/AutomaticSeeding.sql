/*********************************************************************************************
Written By: Matt Lavery
Date:		06/02/2018
Purpose:	This script will report the current state of automatic seeding activities
            Originally published in my personal github https://github.com/Matticusau/SQLDemos/blob/master/SQLAlwaysOnAGAutoSeeding/05.DMVs.sql

SQL Version: SQL 2016 and greater
SQLRAP:		Performance \ SQL Performance

Changes:
Who			When		What


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

-- Based on information in https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/automatic-seeding-secondary-replicas

-- Monitor the status of the automatic seeding
SELECT start_time,
    ag.name,
    db.database_name,
    current_state,
    performed_seeding,
    failure_state,
    failure_state_desc
FROM sys.dm_hadr_automatic_seeding autos 
    JOIN sys.availability_databases_cluster db 
        ON autos.ag_db_id = db.group_database_id
    JOIN sys.availability_groups ag 
        ON autos.ag_id = ag.group_id

-- If a seeding activity is currently in progres then you can also query the following DMV
SELECT * FROM sys.dm_hadr_physical_seeding_stats

