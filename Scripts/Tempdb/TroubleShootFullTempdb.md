# Troubleshoot insufficient disk space in tempdb

| Author | Matt Lavery |
| ------ | ----------- |
| Date | 19/07/2012 |

## Overview
The following information can be used to assist with troubleshooting the situation when the TempDB's data file is full.

This information is largely based on the microsoft document http://msdn.microsoft.com/en-us/library/ms176029.aspx

Applies to SQL 2008, SQL 2008 R2
 
## Troubleshooting Steps
When the TempDb is reported to be full follow these steps:
1. Connect to the SQL Server using SSMS and open a new Query Window

2. Run the following TSQL to check the space allocation of the files within the TempDB and their growth

```SQL
use tempdb
select name
    , (size*1.0/128) as [Size_Mb]
    , (max_size*1.0/128) as [MaxSize_Mb]
    , (growth*1.0/128) as [Growth_Mb]
from sys.database_files
```

3. Check the Amount of Free Space within the TempDB to determine if you need to urgently add additional space to the file

```SQL
SELECT SUM(unallocated_extent_page_count) AS [free pages], 
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;
```

4. Check the amount of storage that is currently allocated to the Version Store within the TempDB. 

    ```SQL
    SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
    (SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
    FROM sys.dm_db_file_space_usage;
    ```

    If you find that this is almost all of the TempDB space or a considerable portion then you may have issues with a long running Transaction. See below.
 
5. Check the amount of space that is allocated for User Objects in the TempDB

    ```SQL
    SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
    (SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
    FROM sys.dm_db_file_space_usage;
    ```

    If you find that it is the User Objects that are consuming the majority of the space then you will need to check what processes are currently running and using the TempDB. See Below. 
 
    Fast view TSQL:

    Use the following to get a fast view of the above checks.

    ```SQL
    SELECT
	    CONVERT(Decimal(9,2), SUM (user_object_reserved_page_count)*1.0/128) as [User_Objects_Mb],
	    CONVERT(Decimal(9,2), SUM (internal_object_reserved_page_count)*1.0/128) as [Internal_Objects_Mb],
	    CONVERT(Decimal(9,2), SUM (version_store_reserved_page_count)*1.0/128)  as [Version_Store_Mb],
	    CONVERT(Decimal(9,2), SUM (unallocated_extent_page_count)*1.0/128) as [FreeSpace_Mb],
	    CONVERT(Decimal(9,2), SUM (mixed_extent_page_count)*1.0/128) as [Mixed_Extent_Page_Mb]
	FROM sys.dm_db_file_space_usage
    ```

## Troubleshooting a large Version Cache in the TempDB

If you find during the initial troubleshooting steps above that it is the Version Cache that is consuming the largest part of the TempDB then use the following to help identify the culprit.

1. Run the following TSQL to identify the oldest Transaction in the TempDB

    ```SQL
    SELECT transaction_id
        , session_id
        , elapsed_time_seconds
        , (elapsed_time_seconds/60/60) as [elapsed_time_hours]
    FROM sys.dm_tran_active_snapshot_database_transactions 
    ORDER BY elapsed_time_seconds DESC;
    ```

    Extract from MS: _A long running transaction that is not related to an online index operation requires a large version store. This version store keeps all the versions generated since the transaction started. Online index build transactions can take a long time to finish, but a separate version store dedicated to online index operations is used. Therefore, these operations do not prevent the versions from other transactions from being removed. For more information, see Row Versioning Resource Usage._
 
2. Gather more information about the suspected cuplrit(s) from the above statement by running the following statement for the appropriate Session_ID's.

    ```SQL
    SELECT session_id
        , login_time
        , host_name
        , program_name
        , login_name
        , status
        , cpu_time
        , memory_usage
        , logical_reads
        , last_request_start_time
        , last_request_end_time
    from sys.dm_exec_sessions
    where session_id in (
    --Insert Session IDs here
    )
    ```

3. To get the TSQL being run by the Session at the time run the following query by replacing the @SessionId variable

    ```SQL
    select st.Text
    from sys.sysprocesses
    CROSS APPLY sys.dm_exec_sql_text(sys.sysprocesses.sql_handle) AS st
    where sys.sysprocesses.spid = @SessionId
    ```

    Once you have identified the culprit(s) then a decision would need to be made based on the information found as to how to react to the culprit.
 
## Troubleshooting a large amount of User Objects in the TempDb
*** TO BE ADDED ***
 
## Reference URLs

Troubleshooting Insufficient Disk Space in tempdb
http://msdn.microsoft.com/en-us/library/ms176029.aspx

Row Versioning Resource Usage
http://msdn.microsoft.com/en-us/library/ms175492.aspx
