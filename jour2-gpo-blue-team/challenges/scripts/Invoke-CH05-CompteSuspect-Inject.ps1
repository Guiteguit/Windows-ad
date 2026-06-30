#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string]$SamAccountName = "backup-admin",

    [string]$AdminGroup = "Admins du domaine"
)

$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$existing = Get-ADUser -Identity $SamAccountName -ErrorAction SilentlyContinue
if ($existing) {
    throw "Le compte '$SamAccountName' existe deja. Nettoyer le challenge ou choisir un autre SamAccountName."
}

$password = ConvertTo-SecureString "P@ssw0rd-Suspect-2026!" -AsPlainText -Force

New-ADUser `
    -Name $SamAccountName `
    -SamAccountName $SamAccountName `
    -UserPrincipalName "$SamAccountName@lab.local" `
    -Path "OU=_Admins,DC=lab,DC=local" `
    -AccountPassword $password `
    -Enabled $true `
    -Description "Compte technique temporaire"

Add-ADGroupMember -Identity $AdminGroup -Members $SamAccountName
Set-ADUser -Identity $SamAccountName -Description "Compte technique temporaire - droits eleves"

Write-Host "[CH05] Injection terminee." -ForegroundColor Yellow
Write-Host ""
Get-ADUser -Identity $SamAccountName -Properties Enabled,Created,Modified,MemberOf |
    Select-Object SamAccountName, Enabled, Created, Modified, MemberOf
Write-Host ""
Get-ADGroupMember -Identity $AdminGroup | Select-Object Name, SamAccountName, objectClass
