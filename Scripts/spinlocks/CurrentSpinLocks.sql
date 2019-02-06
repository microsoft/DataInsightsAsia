--
-- Author:  Matt Lavery
-- Date:    15/10/2018
-- Purpose: Report the spin locks between 5 min workload
--          Based on https://www.sqlskills.com/blogs/paul/advanced-performance-troubleshooting-waits-latches-spinlocks/
--                or https://www.sqlskills.com/blogs/paul/capturing-spinlock-statistics-for-a-period-of-time/
--
--  SQL Version:   SQL 2012 (+ greater)
-- 
--  Version:       0.1.0 
--  Disclaimer:    This script is provided "as is" in accordance with the projects license
--
-- When         Who         What
--------------------------------------------------------------------------------------------
--

-- build the temporary tables
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
    WHERE [name] = N'##TempSpinlockStats1')
    DROP TABLE [##TempSpinlockStats1];
 
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
    WHERE [name] = N'##TempSpinlockStats2')
    DROP TABLE [##TempSpinlockStats2];
GO
 
-- Baseline
SELECT * INTO [##TempSpinlockStats1]
FROM sys.dm_os_spinlock_stats
WHERE [collisions] > 0
ORDER BY [name];
GO
 
-- Now wait...
WAITFOR DELAY '00:00:05';
GO
 
-- Capture updated stats
SELECT * INTO [##TempSpinlockStats2]
FROM sys.dm_os_spinlock_stats
WHERE [collisions] > 0
ORDER BY [name];
GO
 
-- Diff them
SELECT
        '***' AS [New],
        [ts2].[name] AS [Spinlock],
        [ts2].[collisions] AS [DiffCollisions],
        [ts2].[spins] AS [DiffSpins],
        [ts2].[spins_per_collision] AS [SpinsPerCollision],
        [ts2].[sleep_time] AS [DiffSleepTime],
        [ts2].[backoffs] AS [DiffBackoffs]
    FROM [##TempSpinlockStats2] [ts2]
    LEFT OUTER JOIN [##TempSpinlockStats1] [ts1]
        ON [ts2].[name] = [ts1].[name]
    WHERE [ts1].[name] IS NULL
UNION
SELECT
        '' AS [New],
        [ts2].[name] AS [Spinlock],
        [ts2].[collisions] - [ts1].[collisions] AS [DiffCollisions],
        [ts2].[spins] - [ts1].[spins] AS [DiffSpins],
        CASE ([ts2].[spins] - [ts1].[spins]) WHEN 0 THEN 0
            ELSE ([ts2].[spins] - [ts1].[spins]) /
                ([ts2].[collisions] - [ts1].[collisions]) END
                AS [SpinsPerCollision],
        [ts2].[sleep_time] - [ts1].[sleep_time] AS [DiffSleepTime],
        [ts2].[backoffs] - [ts1].[backoffs] AS [DiffBackoffs]
    FROM [##TempSpinlockStats2] [ts2]
    LEFT OUTER JOIN [##TempSpinlockStats1] [ts1]
        ON [ts2].[name] = [ts1].[name]
    WHERE [ts1].[name] IS NOT NULL
    AND [ts2].[collisions] - [ts1].[collisions] > 0
ORDER BY [New] DESC, [Spinlock] ASC;
GO
