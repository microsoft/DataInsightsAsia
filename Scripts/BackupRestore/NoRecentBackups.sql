--
--  Author:        Matt Lavery
--  Date:          23/04/2018
--  Purpose:       Reports database with no recent backup
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  23/04/2018  0.1.0       mlavery     initial script
--  -----------------------------------------------------------------
--

WITH cte_backups (database_name, last_backup_date, compressed_backup_size)
AS
(
    SELECT database_name
        , MAX(backup_start_date) as last_backup_date
        , MAX(compressed_backup_size) as compressed_backup_size
    FROM msdb..backupset
    WHERE type = 'D'
    GROUP BY database_name, type
    -- HAVING MAX(backup_start_date) >- DATEADD(D, -7, GETDATE())
)
SELECT d.Name as database_name
    , cte_backups.last_backup_date
    , cte_backups.compressed_backup_size
FROM master.sys.databases d
LEFT JOIN cte_backups ON cte_backups.database_name = d.Name
WHERE cte_backups.last_backup_date IS NULL