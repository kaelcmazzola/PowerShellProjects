$ErrorActionPreference = "Stop"



<#
.Synopsis
   Retrieves expired accounts. This function must be run on a Domain Controller.
.DESCRIPTION
   This function searches Active Directory for expired accounts.
.EXAMPLE
   Get-DisabledADUsers
#>
function Get-DisabledADUsers{
  Get-ADUser -Filter 'Enabled -eq $false'
}#function Get-DisabledADUsers



<#
.Synopsis
   Retrieves expired accounts and exports them to a specified directory. This function must be run on a Domain Controller.
.DESCRIPTION
   This function searches Active Directory for expired accounts and then exports the output to a .csv in a specified location.
.EXAMPLE
   Export-DisabledADUsers
#>
function Export-DisabledADUsers{
$csvPath = Read-Host -Prompt "Please enter a file path to export to. Example: C:\Users\Administrator\Desktop\YOURFILENAME.csv"

Get-DisabledADUsers | Export-Csv -Path $csvPath -NoTypeInformation
}#function Export-DisabledADUsers



<#
.Synopsis
   Retrieves a .csv file and uses the data in that file to create users in Active Directory. This function must be run on a Domain Controller.
.DESCRIPTION
   This function extracts data from a .csv file and uses it to create users in Active Directory.
.EXAMPLE
   Import-ADUsers
#>
function Import-ADUsers{
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

    New-ADUser -Name "$fname $lname" `
    -GivenName $fname `
    -Surname $lname `
    -UserPrincipalName "$fname.$lname" `
    -Path $OUpath `
    -AccountExpirationDate $expireOn `
    -AccountPassword $secret `
    -ChangePasswordAtLogon $True `
    -Enabled $True `
    -EmailAddress $email `
    -StreetAddress $address `
    -City $city `
    -PostalCode $zipCode `
    -State $state `
    -Country $countryCode `
    -Department $department `
    -OfficePhone $telephone `
    -Title $jobtitle `
    -Company $company `
   
    Write-Output "Account created for $fname $lname in $OUpath"
}
}
}#function Import-ADUsers



<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-LoggedOnUser{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({Test-Connection -ComputerName $_ -Quiet -Count 1})]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    ForEach($computer in $ComputerName){
    
    $output = @{
    'ComputerName' = $computer;
    }#OutputHashTable
    $output.UserName = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer).Username
    [PSCustomObject]$output

    }#ForEach
        
}#function Get-LoggedOnUser



<#
.Synopsis
   Exports a list of logged on users to a .csv in a specified path.
.EXAMPLE
   Export-LoggedOnUser -ComputerName LON-DC1,LON-CL1,LON-SVR1 -Path C:\Users\Administrator.ADATUM\Desktop\LoggedOnUsers2.csv
.EXAMPLE
   Export-LoggedOnUser
#>
function Export-LoggedOnUser{
    [CmdletBinding()]
    [Alias()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]$Path,
    [Parameter(Mandatory=$True)]
    [string[]]$ComputerName
    )
    try{
        Get-LoggedOnUser -ComputerName $ComputerName | Export-Csv -Path $Path -NoTypeInformation -ErrorAction Stop
    }
    catch {
        Write-Host "You need to provide a file path ending with the name of the .csv you want to export."
    }
}#function Export-LoggedOnUser



<#
.Synopsis
   Retrieves information about a computer on the domain.
.DESCRIPTION
   This function retrieves information about a computer on the domain using Get-CimInstance and Get-WMIObject.
.EXAMPLE
   Get-PCProperties -ComputerName COMPUTER1,COMPUTER2
#>
function Get-PCProperties{
   [CmdletBinding()]
   Param(
   [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
   [string[]]$ComputerName 
   )#Param
   PROCESS{
       ForEach($computer in $ComputerName){    
           $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computername
           $boot = $os.LastBootUpTime
           $uptime = $os.LocalDateTime - $os.LastBootUpTime
           $cdrive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='c:'" -ComputerName $computername
           $freespace = $cdrive.FreeSpace /1GB -as [INT]
           $connection = Test-Connection -ComputerName $computername -Count 1 -Quiet
   
       $Properties = [ordered]@{
   
           'Computername' = $computer;
           'OS' = $os.Caption;
           'LastBootUp' = $boot;
           'UpTimeHours' = $uptime;
           #'RunningServices' = $running;
           'C:FreeSpace' = $freespace.ToString("########## GB");
           'Connectivity' = $connection
           #'Connectivity' = Get-PCConnect -computername $computername
   
       }#PropertiesHashTable
   
       $obj = New-Object -TypeName PSObject -Property $properties
   
       Write-Output $obj
   
                       
       }#ForEach
   
   
   }#Process
   
   
   }#function Get-PCProperties



function Get-StyleSheet {
[CmdletBinding()]
Param()
@"
<style>
body {
    font-family:Segoe,Tahoma,Arial,Helvetica;
    font-size:10pt;
    color:#333;
    background-color:#eee;
    margin:10px;
}
th {
    font-weight:bold;
    color:white;
    background-color:#333;
}
</style>
"@
}#function Get-StyleSheet

function New-HTMLReport{
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$ComputerName,

    [Parameter(Mandatory=$True)]
    [string]$ReportFilename
    )

                $frag1 = Get-PCProperties -ComputerName $ComputerName |
                         ConvertTo-HTML -Fragment -As List -PreContent "<h2>Basic Target Computer Info</h2>" |
                         Out-String

                $frag2 = Get-LoggedOnUser -ComputerName $ComputerName |
                         ConvertTo-HTML -Fragment -As Table -PreContent "<h2>Current User</h2>" |
                         Out-String

                $frag3 = Get-ADUser -Properties AccountExpirationDate,LastLogonDate -Filter * | Select-Object Name,DistinguishedName,Enabled,AccountExpirationDate,LastLogonDate -Last 10 |
                         ConvertTo-Html -Fragment -As Table -PreContent "<h2>Newest AD Users</h2>" |
                         Out-String

                $frag4 = Get-ADComputer -Filter * | Select-Object Name,DistinguishedName,Enabled -Last 10 |
                         ConvertTo-Html -Fragment -As Table -PreContent "<h2>Newest AD Computers</h2>" |
                         Out-String

               <# $frag5 = Get-Service -ComputerName $ComputerName | select Status,Name,DisplayName | sort Status,Name |
                         ConvertTo-HTML -Fragment -As Table -PreContent "<h2>Services</h2>" |
                         Out-String

               <# $frag6 = Get-ADUser -Filter * | select Name,Department,Email,AccountExpirationDate |
                         ConvertTo-HTML -Fragment -As Table -PreContent "<h2>Users</h2>" |
                         Out-String
               #>

                $style = Get-StyleSheet

                         ConvertTo-HTML -Title "Report for $ComputerName" `
                         -Head $style `
                         -Body "<h1>Report for $ComputerName</h1>",$frag1,$frag2,$frag3,$frag4 |
                         Out-File $reportfilename
}#function New-HTMLReport



function Get-CoinFlip{
$coin = Get-Random -Minimum 1 -Maximum 3
if($coin -eq 1){Write-Host `n "Heads"}
else{Write-Host `n "Tails"}
}#function Get-CoinFlip






    
   # $ERROR[1].GetType().fullname
