--
--  Author:        Matt Lavery
--  Date:          31/08/2011
--  Purpose:       Reports DB Mirroring status and configuration
--  Reference:     http://blog.matticus.net/2010/08/tsql-to-report-db-mirroring-status-and.html
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  31/08/2011  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

SELECT a.name
    , ISNULL(b.mirroring_role_desc, 'NOT MIRRORED') as [mirroring_role_desc]
    , ISNULL(b.mirroring_state_desc, '') as [mirroring_state_desc]
    , ISNULL(mirroring_safety_level_desc, '') as [mirroring_safety_level_desc]
FROM sys.databases a
INNER JOIN sys.database_mirroring b on b.database_id = a.database_id
WHERE a.name NOT IN ('master', 'msdb', 'model', 'tempdb', 'distribution')
ORDER BY a.name