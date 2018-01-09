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
    ,
    [Parameter(Mandatory=$false)]
    [pscredential]$SqlCredentials
)

# make sure the output path exists
if (!(Test-Path -Path $Path))
{
    New-Item -Path $Path -ItemType Directory | Out-Null;
}

# Import the SQL Module to load the assemblies
if ($null -ne (Get-module -Name SqlServer -ListAvailable -ErrorAction SilentlyContinue))
{
    Import-Module -Name SqlServer;
}
elseif ($null -ne (Get-module -Name SQLPS -ListAvailable -ErrorAction SilentlyContinue)) 
{
    Push-Location;
    Import-Module -Name SQLPS -DisableNameChecking;
    Pop-Location;
}
else 
{
    Write-Error "Neither the SqlServer or SQLPS PowerShell Modules are installed"
    #throw $PSItem;
    Exit; # stop the script execution
}

# Create the SMO object
$smoServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServer);

# if we need to provide SQL Auth credential
if ($null -ne $SqlCredentials)
{
    $smoServer.ConnectionContext.LoginSecure = $false;
    $smoServer.ConnectionContext.Login = $SqlCredentials.UserName;
    $smoServer.ConnectionContext.Password = $SqlCredentials.GetNetworkCredential().Password;
}

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

