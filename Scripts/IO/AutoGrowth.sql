/*********************************************************************************************
Written By: Matt Lavery
Date:		14/02/2013
Purpose:	Report the files with 1mb growth

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


USE master;
GO
SELECT
    database_id
    , db_name(database_id) AS database_name
    , name AS Log_Filename
    , is_percent_growth As growth_in_percentage_set
    , CASE 
            WHEN is_percent_growth = 1 THEN growth else 0 
        END AS Percentage_growth_value
    , CASE 
            WHEN is_percent_growth = 1 THEN CAST((size*8) AS FLOAT) /1024
            ELSE 0 
        END as File_Size_in_MB
    , CASE 
            WHEN is_percent_growth = 1 THEN CAST((size*8*growth) AS FLOAT)/100/1024 
            ELSE CAST((8*growth) AS FLOAT)/1024 
        END AS next_growth_in_MB
    , type_desc AS Filetype
FROM sys.master_files
WHERE
    is_percent_growth = 1
OR 
    (CASE 
        WHEN is_percent_growth = 1 THEN CAST((size*8*growth) AS FLOAT)/100/1024 
        ELSE CAST((8*growth) AS FLOAT)/1024 
    END) = 1

GO

/*
Remediation

    USE master;
    GO
    ALTER DATABASE [database name] MODIFY FILE ( NAME = N'[Filename] ', FILEGROWTH = [value]KB );

*/