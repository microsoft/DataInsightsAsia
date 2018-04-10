# 
# Author: Matt Lavery
# Date:   10/04/2018
# Purpose: Functions for working with SQL Server Policies
#          For recommended policies see https://docs.microsoft.com/en-us/sql/relational-databases/policy-based-management/monitor-and-enforce-best-practices-by-using-policy-based-management
# 
# History
# When        Version     Who         What
# -----------------------------------------------------------------
# 10/04/2018  0.1.0       Mlavery     Initial coding
# -----------------------------------------------------------------
#

<#
.SYNOPSIS
    Return policy name and description for best practice policies
.DESCRIPTION
    Return policy name and description for best practice policies
    For recommended policies see https://docs.microsoft.com/en-us/sql/relational-databases/policy-based-management/monitor-and-enforce-best-practices-by-using-policy-based-management
.EXAMPLE
    PS C:\> Get-PolicyInfo
    Outputs the policy documentation for ALL policy files found on disk
.EXAMPLE
    PS C:\> Get-PolicyInfo -Policies @('Data and Log File Location.xml','Database Page Status.xml','Database Page Verification.xml','SQL Server Password Policy.xml')
    Outputs the policy documentation for the supplied policies
.NOTES
    This code is provided "as is" under the given license.
#>
function Get-PolicyInfo
{
    [CmdletBinding()]
    Param(
        # The policies to invoke
        [string[]]
        $Policies = @('Data and Log File Location.xml','Database Page Status.xml','Database Page Verification.xml','SQL Server Password Policy.xml')    
    )

    process {
        $policyXmls = Get-ChildItem -Path 'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Policies\DatabaseEngine\1033' -Filter '*.xml' | Where-Object -Name -In $Policies | Sort-Object -Property BaseName;
        
        $policyObj = @();
        foreach ($policyFile in $policyXmls)
        {
            $policyObj += [PSCustomObject]@{
                FileName = $policyFile.BaseName;
                Description = ([xml](Get-Content -Path $policyFile.FullName)).Model.bufferSchema.definitions.document.data.schema.bufferData.instances.document[0].data.Policy.Description.InnerText;
            }
        }

        return $policyObj;
    }
}


<#
.SYNOPSIS
    Evaluates the given policy
.DESCRIPTION
    Evaluates the given policy
.EXAMPLE
    PS C:\> Invoke-Policies -SqlServer 'MyServer\Prod01' -Policies @('Data and Log File Location.xml','Database Page Status.xml','Database Page Verification.xml','SQL Server Password Policy.xml')
    Evaluates the supplied policies against the server 'MyServer\Prod01'
.NOTES
    This code is provided "as is" under the given license.
#>
function Invoke-Policies
{
    [CmdletBinding()]
    Param(
        # The Sql Server to execute policies against (e.g. MyServer\Prod01)
        [string]
        $SqlServer
        ,
        # The policies to invoke
        [string[]]
        $Policies = @('Data and Log File Location.xml','Database Page Status.xml','Database Page Verification.xml','SQL Server Password Policy.xml')
        
    )

    process {
        $policyXmls = Get-ChildItem -Path 'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Policies\DatabaseEngine\1033' -Filter '*.xml' | Where-Object -Name -In $Policies | Sort-Object -Property BaseName;
        
        $policyXmls | Invoke-PolicyEvaluation –TargetServerName $SqlServer;
    }
}
