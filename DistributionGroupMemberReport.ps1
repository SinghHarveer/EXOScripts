###The script was downloaded from Technet gallery back in the days when it used to be active###
<#

.Requires -version 2 - Runs in Exchange Management Shell

.SYNOPSIS
.\DistributionGroupMemberReport.ps1 - It Can Display all the Distribution Group and its members on a List

Or It can Export to a CSV file


Example 1

[PS] C:\DG>.\DistributionGroupMemberReport.ps1


Distribution Group Member Report
----------------------------

1.Display in Shell

2.Export to CSV File

Choose The Task: 1

DisplayName                   Alias                         Primary SMTP address          Distriubtion Group
-----------                   -----                         --------------------          ------------------
Atlast1                       Atlast1                       Atlast1@azure365pro.com       Test1

Example 2

[PS] C:\DG>.\DistributionGroupMemberReport.ps1


Distribution Group Member Report
----------------------------

1.Display in Shell

2.Export to CSV File

Choose The Task: 2
Enter the Path of CSV file (Eg. C:\DG.csv): C:\DGmembers.csv

.Author
Written By: Satheshwaran Manoharan

Change Log
V1.0, 11/10/2012 - Initial version

Change Log
V1.1, 02/07/2014 - Added "Enter the Distribution Group name with Wild Card"



#>

Write-host "

Distribution Group Member Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

3.Enter the Distribution Group name with Wild Card (Export)

4.Enter the Distribution Group name with Wild Card (Display)

Dynamic Distribution Group Member Report
----------------------------

5.Display in Exchange Management Shell

6.Export to CSV File

7.Enter the Dynamic Distribution Group name with Wild Card (Export)

8.Enter the Dynamic Group name with Wild Card (Display)"-ForeGround "Cyan"

#----------------
# Script
#----------------

Write-Host "               "

$number = Read-Host "Choose The Task"
$output = @()
switch ($number) 
{

1 {

$AllDG = Get-DistributionGroup -resultsize unlimited
Foreach($dg in $allDg)
 {
$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited


if($members.count -eq 0)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }
else
{
Foreach($Member in $members)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $member.Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }

}

  }

;Break}

2 {

$i = 0 

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)" 

$AllDG = Get-DistributionGroup -resultsize unlimited

Foreach($dg in $allDg)
{
$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

if($members.count -eq 0)
{
$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.GroupType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

}
else
{
Foreach($Member in $members)
 {

$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $Member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Member.Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Member.RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Member.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.GroupType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

 }
}
# update counters and write progress
$i++
Write-Progress -activity "Scanning Groups . . ." -status "Scanned: $i of $($allDg.Count)" -percentComplete (($i / $allDg.Count)  * 100)
$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

}

;Break}

3 {

$i = 0 

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)" 

$Dgname = Read-Host "Enter the DG name or Range (Eg. DGname , DG*,*DG)"

$AllDG = Get-DistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

if($members.count -eq 0)
{
$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.GroupType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

}
else
{
Foreach($Member in $members)
 {

$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $Member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Member.Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Member.RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Member.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.GroupType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

 }
}
# update counters and write progress
$i++
Write-Progress -activity "Scanning Groups . . ." -status "Scanned: $i of $($allDg.Count)" -percentComplete (($i / $allDg.Count)  * 100)
$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

}

;Break}

4 {

$Dgname = Read-Host "Enter the DG name or Range (Eg. DGname , DG*,*DG)"

$AllDG = Get-DistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

 {

$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

if($members.count -eq 0)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }
else
{
Foreach($Member in $members)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $member.Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }

}

  }

;Break}

5 {

$AllDG = Get-DynamicDistributionGroup -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

if($members.count -eq 0)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }
else
{
Foreach($Member in $members)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $member.Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }

}

  }

;Break}

6 {
$i = 0 

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DYDG.csv)" 

$AllDG = Get-DynamicDistributionGroup -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

if($members.count -eq 0)
{
$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

}
else
{
Foreach($Member in $members)
 {

$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $Member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Member.Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Member.RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Member.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

 }
}
# update counters and write progress
$i++
Write-Progress -activity "Scanning Groups . . ." -status "Scanned: $i of $($allDg.Count)" -percentComplete (($i / $allDg.Count)  * 100)
$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

}

;Break}

7 {
$i = 0 

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DYDG.csv)" 

$Dgname = Read-Host "Enter the DG name or Range (Eg. DynmicDGname , Dy*,*Dy)"

$AllDG = Get-DynamicDistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

if($members.count -eq 0)
{
$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmptyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

}
else
{
Foreach($Member in $members)
 {

$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
$manageremail = Get-Mailbox $managers.DistributionGroupManagers -ErrorAction SilentlyContinue -resultsize unlimited

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $Member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Member.Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Member.RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Member.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers Primary SMTP address" -Value $manageremail.primarysmtpaddress
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Not Allowed from Internet" -Value $DG.RequireSenderAuthenticationEnabled

$output += $UserObj  

 }
}
# update counters and write progress
$i++
Write-Progress -activity "Scanning Groups . . ." -status "Scanned: $i of $($allDg.Count)" -percentComplete (($i / $allDg.Count)  * 100)
$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

}

;Break}

8 {

$Dgname = Read-Host "Enter the Dynamic DG name or Range (Eg. DynamicDGname , DG*,*DG)"

$AllDG = Get-DynamicDistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

if($members.count -eq 0)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Alias" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmtpyGroup
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }
else
{
Foreach($Member in $members)
 {
$userObj = New-Object PSObject
$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $member.Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $member.Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $member.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
Write-Output $Userobj
 }

}

  }

;Break}

Default {Write-Host "No matches found , Enter Options 1 or 2" -ForeGround "red"}

}
