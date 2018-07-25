--
--  Author:        Matt Lavery
--  Date:          25/07/2018
--  Purpose:       Reports the available Actions, Events, and Targets for XEL
--  Reference:     https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-db-diff-from-svr
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--
--  -----------------------------------------------------------------
--

SELECT
    o.object_type,
    p.name         AS [package_name],
    o.name         AS [db_object_name],
    o.description  AS [db_obj_description]
FROM
                sys.dm_xe_objects  AS o
    INNER JOIN sys.dm_xe_packages AS p  ON p.guid = o.package_guid
WHERE
    o.object_type in
        (
        'action',  
        'event',  
        'target'
        )
        --AND 
        --o.name like '%severity%'
ORDER BY
    o.object_type,
    p.name,
    o.name;
    