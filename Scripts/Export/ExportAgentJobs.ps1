# 
# Author: Matt Lavery
# Date:   13/04/2017
# Purpose: Scripts out the Agent Jobs from a SQL instance
# 

#load the required assemblies via the provided script
Push-Location;
Import-Module SQLPS;
Pop-Location;

# Create the SMO object
$smoServer = New-Object Microsoft.SqlServer.Management.Smo.Server("SVR-SQL16");

# Create a Scripter object and set the required scripting options.
$scrp = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Scripter -ArgumentList ($smoServer);

$scrp.Options.ScriptDrops = $false;
$scrp.Options.WithDependencies = $true;
$scrp.Options.IncludeIfNotExists = $true;

#Method 1 – Multiline script appropriate
foreach ($job in $smoServer.JobServer.Jobs)
{  
    "/* Agent Job: $($job.Name) */" | Out-File -FilePath "C:\scripts\Jobs.sql" -Append;
    $job.Script() | Out-File -FilePath "C:\scripts\Jobs.sql" -Append;
}

