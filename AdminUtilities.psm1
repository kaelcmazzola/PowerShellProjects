<#
.Synopsis
   Retrieves expired accounts. This function must be run on a Domain Controller.
.DESCRIPTION
   This function searches Active Directory for expired accounts.
.EXAMPLE
   Get-DisabledADUsers
#>
function Get-DisabledADUsers
{
  Get-ADUser -Filter 'Enabled -eq $false'

}



<#
.Synopsis
   Retrieves expired accounts and exports them to a specified directory. This function must be run on a Domain Controller.
.DESCRIPTION
   This function searches Active Directory for expired accounts and then exports the output to a .csv in a specified location.
.EXAMPLE
   Export-DisabledADUsers
#>
function Export-DisabledADUsers
{
$csvPath = Read-Host -Prompt "Please enter a file path to export to. Example: C:\Desktop\YOURFILENAME.csv"

Get-DisabledADUsers | Export-Csv -Path $csvPath

}