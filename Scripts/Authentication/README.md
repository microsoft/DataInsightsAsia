# Kerberos Authentication Scripts

A collection of scripts and links for working with kerberos

For the official guidance on kerberos read [Register a Service Principal Name for Kerberos Connections](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/register-a-service-principal-name-for-kerberos-connections)

For instructions on how to configure permissions to allow dynamic SPN registration on service start/stop read [How to use Kerberos authentication in SQL Server](https://support.microsoft.com/en-us/help/319723/how-to-use-kerberos-authentication-in-sql-server)

## Microsoft® Kerberos Configuration Manager for SQL Server®

For working with Kerberos it is highly recommended to use the Kerberos Configuration Manager to troubleshoot issues with SPN registration.

Blog: https://support.microsoft.com/en-us/help/2985455/kerberos-configuration-manager-for-sql-server-is-available
Download: https://www.microsoft.com/en-us/download/details.aspx?id=39046

## AuthenticationSummary.sql
A script for reporting on what authentication protocols are used by current connections

## RemoteConnectionsUsingNTLM.sql
A script for reporting on remote connections using NTLM

# License
All code is provided "as is" as per the [MIT License](https://github.com/Microsoft/DataInsightsAsia/blob/master/LICENSE).



