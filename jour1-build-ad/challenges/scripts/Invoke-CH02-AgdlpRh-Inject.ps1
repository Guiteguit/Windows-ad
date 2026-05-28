#Requires -RunAsAdministrator

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$GlobalGroup = "GG_RH"
$DomainLocalGroup = "DL_SHARE_RH_RW"

$sourceGroup = Get-ADGroup -Identity $GlobalGroup -ErrorAction SilentlyContinue
if (-not $sourceGroup) {
    throw "Groupe '$GlobalGroup' introuvable. Verifier que le TP03 est termine."
}

$targetGroup = Get-ADGroup -Identity $DomainLocalGroup -ErrorAction SilentlyContinue
if (-not $targetGroup) {
    throw "Groupe '$DomainLocalGroup' introuvable. Verifier que le TP03 est termine."
}

$isMember = Get-ADGroupMember -Identity $DomainLocalGroup -Recursive:$false |
    Where-Object { $_.SamAccountName -eq $GlobalGroup -or $_.Name -eq $GlobalGroup }

if ($isMember) {
    Remove-ADGroupMember -Identity $DomainLocalGroup -Members $GlobalGroup -Confirm:$false
}

Write-Host "[CH02] Injection terminee." -ForegroundColor Yellow
Write-Host "[CH02] Un incident AGDLP est maintenant present dans le domaine." -ForegroundColor Yellow
Write-Host ""
Get-ADGroupMember -Identity $DomainLocalGroup | Select-Object Name, SamAccountName, objectClass
