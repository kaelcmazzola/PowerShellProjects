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
$csvPath = Read-Host -Prompt "Please enter a file path to export to. Example: C:\Users\Administrator\Desktop\YOURFILENAME.csv"

Get-DisabledADUsers | Export-Csv -Path $csvPath

}



<#
.Synopsis
   Retrieves a .csv file and uses the data in that file to create users in Active Directory. This function must be run on a Domain Controller.
.DESCRIPTION
   This function extracts data from a .csv file and uses it to create users in Active Directory.
.EXAMPLE
   Import-ADUsers
#>
function Import-ADUsers
{
[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
[string[]]$FilePath
)#Param
PROCESS{

$secret = ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force

#$FilePath = Read-Host -Prompt "Enter the filepath to the .csv you are importing. Example: C:\Users\Administrator\Desktop\YOURFILENAME.csv"

$users = Import-Csv $FilePath

foreach ($user in $users)
{
    $fname = $user.firstname
    #$midInitial = $user.middleInitial
    $lname = $user.lastname
    #$active = $user.Enabled
    $email = $user.email
    $address = $user.streetaddress
    $city = $user.city
    $zipCode = $user.zipcode
    $state = $user.state
    $countryCode = $user.countrycode
    $department = $user.department
    #$password = $user.password
    $telephone = $user.telephone
    $jobtitle = $user.jobtitle
    $company = $user.company
    #$fullName = $user.Name
    #$class = $user.ObjectClass
    $OUpath = $user.ou
    #$mailDomain = $user.maildomain
    $expireOn = (Get-Date).AddDays(365)

    New-ADUser -Name "$fname $lname" -GivenName $fname -Surname $lname -UserPrincipalName "$fname.$lname" -Path $OUpath -AccountExpirationDate $expireOn -AccountPassword $secret -ChangePasswordAtLogon $True -Enabled $True -EmailAddress $email -StreetAddress $address -City $city -PostalCode $zipCode -State $state -Country $countryCode -Department $department -OfficePhone $telephone -Title $jobtitle -Company $company
   
    Write-Output "Account created for $fname $lname in $OUpath"
}
}
}
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet

function Verb-Noun
{

}
#>