--
--  Author:        Matt Lavery
--  Date:          06/02/2018
--  Purpose:       This script will report the current state of automatic seeding activities
--                 Originally published in my personal github https://github.com/Matticusau/SQLDemos/blob/master/SQLAlwaysOnAGAutoSeeding/05.DMVs.sql
--  SQL Version:   SQL 2016 and greater
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  06/02/2018  0.1.1       mlavery     Initial code
--  -----------------------------------------------------------------
--

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

