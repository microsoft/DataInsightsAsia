# Backup and Restore
A collection of resources to assist with backup and restore processes. 

## SmartDBRestore.sql
A script to provide a smart approach to restore processes.
Only restores the most recent .BAK file from a configured directory to a specified database
Fixes any orphaned users by mapping to logins with the same name (sid mismatch)

## SmartLogShippingFailover.sql
A script to provide automate the restore of any log shipped databases following a failover. 


# License
All code is provided "as is" as per the [MIT License](https://github.com/Microsoft/DataInsightsAsia/blob/master/LICENSE).
