--
--  Author:        Matt Lavery
--  Date:          09/04/2018
--  Purpose:       Check for db_roles which belong to other db_roles
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  09/04/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

exec sp_MSforeachdb 'use [?];
if (DB_NAME() <> ''msdb'')
BEGIN
    WITH dbpricipals_cte (principal_id, name)
    AS
    (
        SELECT p1.principal_id
            , p1.name 
        FROM sys.database_principals as p1
        WHERE  p1.type = ''R''
    )  
    SELECT db_name() [db_name]
        , p.[name] [role_name]
        , r.[name] [nested_role_name]
    FROM sys.database_role_members as m
    INNER JOIN sys.database_principals as p
        ON p.principal_id = m.role_principal_id
        AND p.type = ''R''
    INNER JOIN dbpricipals_cte r ON r.principal_id = m.member_principal_id
END'
