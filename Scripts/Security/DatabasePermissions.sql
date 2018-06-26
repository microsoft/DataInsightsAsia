--
--  Author:        Matt Lavery
--  Date:          09/04/2018
--  Purpose:       Reports database permissions
--  Reference:     http://blog.matticus.net/2011/06/tsql-to-list-all-permissions-within.html
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  09/04/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

select DB_NAME() as [dbname]
    , sys.database_permissions.class_desc
    , sys.database_permissions.type
    , sys.database_permissions.permission_name
    , sys.database_permissions.state
    , sys.database_permissions.state_desc
    , sys.database_principals.name as [grantee_principal_name]
    , ISNULL(sys.schemas.name, '') as [schema_name]
    , ISNULL(AllObjects.name, '') as [object_name]
    -- , (CASE 
    --     WHEN sys.database_permissions.class = 0 THEN 'GRANT ' + sys.database_permissions.permission_name + ' TO [' + sys.database_principals.name + '];'
    --     ELSE 'GRANT ' + sys.database_permissions.permission_name + ' ON [' + sys.schemas.name + '].[' + AllObjects.name + '] TO [' + sys.database_principals.name + '];'
    --     END) as [Grant_Perms_Stmnt]
    -- , (CASE 
    --     WHEN sys.database_permissions.class = 0 THEN 'DENY ' + sys.database_permissions.permission_name + ' TO [' + sys.database_principals.name + '];'
    --     ELSE 'DENY ' + sys.database_permissions.permission_name + ' ON [' + sys.schemas.name + '].[' + AllObjects.name + '] TO [' + sys.database_principals.name + '];'
    --     END) as [Deny_Perms_Stmnt]
    -- , (CASE 
    --     WHEN sys.database_permissions.class = 0 THEN 'REVOKE ' + sys.database_permissions.permission_name + ' FROM [' + sys.database_principals.name + '];'
    --     ELSE 'REVOKE ' + sys.database_permissions.permission_name + ' ON [' + sys.schemas.name + '].[' + AllObjects.name + '] FROM [' + sys.database_principals.name + '];'
    --     END) as [Revoke_Perms_Stmnt]
FROM sys.database_permissions
INNER JOIN sys.database_principals ON sys.database_principals.principal_id = sys.database_permissions.grantee_principal_id
    --AND sys.database_principals.name = 'public' --uncomment this line to restrict the output to a single principal
LEFT JOIN (
    SELECT name, object_id, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date, is_ms_shipped, is_published, is_schema_published
    FROM sys.objects
    UNION
    SELECT name, object_id, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date, is_ms_shipped, is_published, is_schema_published
    FROM sys.system_objects
) AllObjects ON AllObjects.object_id = sys.database_permissions.major_id
LEFT JOIN sys.schemas ON sys.schemas.schema_id = AllObjects.schema_id
    -- AND sys.schemas.name <> 'sys' -- uncomment this line to exclude system objects
--WHERE sys.database_permissions.permission_name NOT IN ('REFERENCES') -- uncomment to filter permission names
ORDER BY sys.database_principals.name
    , sys.database_permissions.class
    , sys.schemas.name
    , AllObjects.name
