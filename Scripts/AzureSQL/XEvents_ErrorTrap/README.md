# XEvents ErrorTrap session

Scripts to create and work with an Extended Events Session called ***error_trap_xel*** for trapping errors on a Azure SQL Database

The scripts are provided in a step-by-step format

Target platforms

- Azure SQL Database
- Managed Instance

Reference information
[https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-db-diff-from-svr](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-db-diff-from-svr)
[https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-code-ring-buffer](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-xevent-code-ring-buffer)
[http://sqlblog.com/blogs/davide_mauri/archive/2013/03/17/trapping-sql-server-errors-with-extended-events.aspx](http://sqlblog.com/blogs/davide_mauri/archive/2013/03/17/trapping-sql-server-errors-with-extended-events.aspx)

## 01.AvailableActionEventTargets.sql

Script to create the session with a target to the ringbuffer

## 02.Setup.sql

Script to create the session with a target to the ringbuffer

## 03.Report.sql

Use this script to query the data in the ring buffer. Full details of the event is avaialble in the raw XML.

## 04.DisableRingBufferAndXEvent.sql

Clean up script to run when finished with work to disable the XEvent session and remove the RingBuffer

# License

All code is provided "as is" as per the [MIT License](https://github.com/Microsoft/DataInsightsAsia/blob/master/LICENSE).
