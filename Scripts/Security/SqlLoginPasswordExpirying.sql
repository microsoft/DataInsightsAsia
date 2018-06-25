--
--  Author:        Matt Lavery
--  Date:          09/04/2018
--  Purpose:       Reports when sql logins passwords will expire
--  Reference:	   https://gallery.technet.microsoft.com/scriptcenter/When-will-a-SQL-login-d6fbb6df#content
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  09/04/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

-- When will a SQL login password expire? 
SELECT SL.name AS LoginName 
      ,LOGINPROPERTY (SL.name, 'PasswordLastSetTime') AS PasswordLastSetTime 
      ,LOGINPROPERTY (SL.name, 'DaysUntilExpiration') AS DaysUntilExpiration 
      ,DATEADD(dd, CONVERT(int, LOGINPROPERTY (SL.name, 'DaysUntilExpiration')) 
                 , CONVERT(datetime, LOGINPROPERTY (SL.name, 'PasswordLastSetTime'))) AS PasswordExpiration 
      ,SL.is_policy_checked AS IsPolicyChecked 
      ,LOGINPROPERTY (SL.name, 'IsExpired') AS IsExpired 
      ,LOGINPROPERTY (SL.name, 'IsMustChange') AS IsMustChange 
      ,LOGINPROPERTY (SL.name, 'IsLocked') AS IsLocked 
      ,LOGINPROPERTY (SL.name, 'LockoutTime') AS LockoutTime 
      ,LOGINPROPERTY (SL.name, 'BadPasswordCount') AS BadPasswordCount 
      ,LOGINPROPERTY (SL.name, 'BadPasswordTime') AS BadPasswordTime 
      ,LOGINPROPERTY (SL.name, 'HistoryLength') AS HistoryLength 
FROM sys.sql_logins AS SL 
WHERE is_expiration_checked = 1 
ORDER BY LOGINPROPERTY (SL.name, 'PasswordLastSetTime') DESC

