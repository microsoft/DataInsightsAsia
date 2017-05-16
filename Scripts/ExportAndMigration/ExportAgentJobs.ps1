# 
# Author: Matt Lavery
# Date:   13/04/2017
# Purpose: Scripts out the Agent Jobs from a SQL instance
# 
Param(
    [Parameter(mandatory=$true)]
    [string]$SqlServer = "localhost"

    , [Parameter(mandatory=$false)]
    [string]$Path = "C:\Output"
)

# make sure the output path exists
if (!(Test-Path -Path $Path))
{
    New-Item -Path $Path -ItemType Directory | Out-Null;
}

#load the required assemblies via the provided script
Push-Location;
Import-Module SQLPS;
Pop-Location;

# Create the SMO object
$smoServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServer);

# Create a Scripter object and set the required scripting options.
$scrp = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Scripter -ArgumentList ($smoServer);

$scrp.Options.ScriptDrops = $false;
$scrp.Options.WithDependencies = $true;
$scrp.Options.IncludeIfNotExists = $true;

# build the path to the file to save the scripts too
[string]$outputFilePath = Join-Path -Path $Path -ChildPath 'Jobs.sql';

#Method 1 – Multiline script appropriate
foreach ($job in $smoServer.JobServer.Jobs)
{  
    "/* Agent Job: $($job.Name) */" | Out-File -FilePath $outputFilePath -Append;
    $job.Script() | Out-File -FilePath $outputFilePath -Append;
}

