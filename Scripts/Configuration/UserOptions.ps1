<#
    Author:        Matt Lavery
    Date:          16/05/2017
    Purpose:       Provides a way of reporting which User Options are enabled
    Major Version: 0.1.0 
    Reference:     https://technet.microsoft.com/en-us/library/ms176031%28v=sql.105%29.aspx?f=255&MSPPError=-2147217396

    History
    When        Version     Who         What
    -----------------------------------------------------------------
    16/05/2017  0.1.0       Mlavery     Initial coding
    -----------------------------------------------------------------
#>


<#
.SYNOPSIS
    Determines which User Option flags are enabled for a given configuration value.
.DESCRIPTION
    The configuration value in sp_configure 'user_options', is stored as a bit value which is the make up of the enabled flags bit values.
    This function will take that value and perform a bitwise comparison to determine the enabled bit flags
.EXAMPLE
    PS C:\> . .\UserOptions.ps1
    PS C:\> Get-CurrentUserOptions -CurrentUserOptions 4472;
    This example loads the script/function into the session, then calls the function to determine which UserOptions are enabled for the BIT value 4472 
.INPUTS
    CurrentUserOptions is the current value returned by EXEC sp_configure 'user_options'
.OUTPUTS
    A table of the enabled user options
.NOTES
    This code is provided "as is" under the given license.
#>
function Get-CurrentUserOptions
{
    [CmdLetBinding()]
    param(
        [Parameter(mandatory=$true, ParameterSetName='Current')]
        [int]$CurrentUserOptions
    )


    $userOptions = @(
        [PSCustomObject]@{
            Name = 'DISABLE_DEF_CNST_CHK';
            Value = 1;
            Description = 'Controls interim or deferred constraint checking.';
        }
        , [PSCustomObject]@{
            Name = 'IMPLICIT_TRANSACTIONS';
            Value = 2;
            Description = 'For dblib network library connections, controls whether a transaction is started implicitly when a statement is executed. The IMPLICIT_TRANSACTIONS setting has no effect on ODBC or OLEDB connections.';
        }
        , [PSCustomObject]@{
            Name = 'CURSOR_CLOSE_ON_COMMIT';
            Value = 4;
            Description = 'Controls behavior of cursors after a commit operation has been performed.';
        }
        , [PSCustomObject]@{
            Name = 'ANSI_WARNINGS';
            Value = 8;
            Description = 'Controls truncation and NULL in aggregate warnings.';
        }
        , [PSCustomObject]@{
            Name = 'ANSI_PADDING';
            Value = 16;
            Description = 'Controls padding of fixed-length variables.';
        }
        , [PSCustomObject]@{
            Name = 'ANSI_NULLS';
            Value = 32;
            Description = 'Controls NULL handling when using equality operators.';
        }
        , [PSCustomObject]@{
            Name = 'ARITHABORT';
            Value = 64;
            Description = 'Terminates a query when an overflow or divide-by-zero error occurs during query execution.';
        }
        , [PSCustomObject]@{
            Name = 'ARITHIGNORE';
            Value = 128;
            Description = 'Returns NULL when an overflow or divide-by-zero error occurs during a query.';
        }
        , [PSCustomObject]@{
            Name = 'QUOTED_IDENTIFIER';
            Value = 256;
            Description = 'Differentiates between single and double quotation marks when evaluating an expression.';
        }
        , [PSCustomObject]@{
            Name = 'NOCOUNT';
            Value = 512;
            Description = 'Turns off the message returned at the end of each statement that states how many rows were affected.';
        }
        , [PSCustomObject]@{
            Name = 'ANSI_NULL_DFLT_ON';
            Value = 1024;
            Description = "Alters the session's behavior to use ANSI compatibility for nullability. New columns defined without explicit nullability are defined to allow nulls.";
        }
        , [PSCustomObject]@{
            Name = 'ANSI_NULL_DFLT_OFF';
            Value = 2048;
            Description = "Alters the session's behavior not to use ANSI compatibility for nullability. New columns defined without explicit nullability do not allow nulls.";
        }
        , [PSCustomObject]@{
            Name = 'CONCAT_NULL_YIELDS_NULL';
            Value = 4096;
            Description = 'Returns NULL when concatenating a NULL value with a string.';
        }
        , [PSCustomObject]@{
            Name = 'NUMERIC_ROUNDABORT';
            Value = 8192;
            Description = 'Generates an error when a loss of precision occurs in an expression.';
        }
        , [PSCustomObject]@{
            Name = 'XACT_ABORT';
            Value = 16384;
            Description = 'Rolls back a transaction if a Transact-SQL statement raises a run-time error.';
        }
    )



    # report what user options are currently enabled
    $userOptions | Where-Object { $PSItem.Value -band $CurrentUserOptions } | Format-Table Name, Description;

}

