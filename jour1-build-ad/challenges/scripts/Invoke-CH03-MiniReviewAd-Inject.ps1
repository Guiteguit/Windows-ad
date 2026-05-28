#Requires -RunAsAdministrator

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$DomainDn = "DC=lab,DC=local"
$ComputersContainer = "CN=Computers,$DomainDn"
$UsersItOu = "OU=IT,OU=_Utilisateurs,$DomainDn"
$GroupsOu = "OU=Global-Groups,OU=_Groupes,$DomainDn"
$ClientName = "CLIENT01"
$UnusedGroup = "GG_UNUSED_OLD"
$BadAdmin = "adm.shared"
$DirectUser = "user.rh1"
$RhPermissionGroup = "DL_SHARE_RH_RW"

$requiredPaths = @(
    $ComputersContainer,
    $UsersItOu,
    $GroupsOu
)

foreach ($path in $requiredPaths) {
    $object = Get-ADObject -Identity $path -ErrorAction SilentlyContinue
    if (-not $object) {
        throw "Objet AD introuvable : $path"
    }
}

$computer = Get-ADComputer -Identity $ClientName -ErrorAction Stop
Move-ADObject -Identity $computer.DistinguishedName -TargetPath $ComputersContainer

if (-not (Get-ADGroup -Identity $UnusedGroup -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name $UnusedGroup -SamAccountName $UnusedGroup -GroupScope Global -GroupCategory Security -Path $GroupsOu
}

if (-not (Get-ADUser -Identity $BadAdmin -ErrorAction SilentlyContinue)) {
    $password = ConvertTo-SecureString "P@ssw0rd-2026!" -AsPlainText -Force
    New-ADUser -Name $BadAdmin -SamAccountName $BadAdmin -UserPrincipalName "$BadAdmin@lab.local" -Path $UsersItOu -AccountPassword $password -Enabled $true -ChangePasswordAtLogon $false
}

$directMembership = Get-ADGroupMember -Identity $RhPermissionGroup -Recursive:$false |
    Where-Object { $_.SamAccountName -eq $DirectUser }

if (-not $directMembership) {
    Add-ADGroupMember -Identity $RhPermissionGroup -Members $DirectUser
}

Write-Host "[CH03] Injection terminee." -ForegroundColor Yellow
Write-Host "[CH03] Plusieurs ecarts d'hygiene AD sont maintenant presents." -ForegroundColor Yellow
Write-Host ""
Get-ADComputer $ClientName -Properties DistinguishedName | Select-Object Name, DistinguishedName
Get-ADGroup -Filter "Name -like 'GG_UNUSED*'" | Select-Object Name, DistinguishedName
Get-ADUser -Filter "SamAccountName -eq '$BadAdmin'" -Properties DistinguishedName | Select-Object Name, SamAccountName, DistinguishedName
Get-ADGroupMember $RhPermissionGroup | Select-Object Name, SamAccountName, objectClass
