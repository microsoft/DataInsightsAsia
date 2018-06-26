--
--  Author:        Matt Lavery
--  Date:          09/04/2018
--  Purpose:       Checks for expired/expirying certificates
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
--  History
--  When        Version     Who         What
--  -----------------------------------------------------------------
--  09/04/2018  0.1.0       Mlavery     Initial coding
--  -----------------------------------------------------------------
--

use master
GO
SELECT * 
FROM sys.certificates
WHERE expiry_date <= DATEADD(dd,+30,GETDATE()) -- expirying in 30 days
ORDER BY expiry_date DESC