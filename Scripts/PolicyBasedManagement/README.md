# Policy Based Management scripts
A collection of scripts for using and managing Policy Based Management of SQL Server

Recommend considering the [Enterprise Policy Management Framework](http://aka.ms/epmframework) if you are keen on Policy Based Management.

## PolicyFunctions.ps1
Contains a few functions for managing and interacting with Policies.

```
. .\PolicyFunctions.ps1

$policies = @('Data and Log File Location.xml','Database Page Status.xml','Database Page Verification.xml','SQL Server Password Policy.xml')

# get the name and description of the supplied policies
Get-PolicyInfo -Policies $policies

# evaluate the given policies
Invoke-Policies -SqlServer 'MyServer\Prod01' -Policies $policies
```

# License
All code is provided "as is" as per the [MIT License](https://github.com/Microsoft/DataInsightsAsia/blob/master/LICENSE).
