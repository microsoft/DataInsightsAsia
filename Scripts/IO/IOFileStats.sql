/*********************************************************************************************
Written By: Matt Lavery
Date:		14/02/2013
Purpose:	Report the IO File Stats

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
suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise 
or result from the use or distribution of the Sample Code.
*********************************************************************************************/


SELECT
    DB_NAME(mf.database_id) AS databaseName
    , name AS File_LogicalName
    , CASE
            WHEN type_desc = 'LOG' THEN 'Log File'
            WHEN type_desc = 'ROWS' THEN 'Data File'
            ELSE type_desc
        END AS File_type_desc
    , mf.physical_name
    , num_of_reads
    , num_of_bytes_read
    , io_stall_read_ms
    , num_of_writes
    , num_of_bytes_written
    , io_stall_write_ms
    , io_stall
    , size_on_disk_bytes
    , size_on_disk_bytes/ 1024 AS size_on_disk_KB
    , size_on_disk_bytes/ 1024 / 1024 AS size_on_disk_MB
    , size_on_disk_bytes/ 1024 / 1024 / 1024 AS size_on_disk_GB
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs
JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id
AND mf.FILE_ID = divfs.FILE_ID
ORDER BY num_of_Reads DESC

