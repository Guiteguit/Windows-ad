#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string]$GpoName = "GPO_SECURITE_POSTES",

    [string]$TargetOu = "OU=Workstations,OU=_Postes,DC=lab,DC=local"
)

$ErrorActionPreference = "Stop"

Import-Module GroupPolicy

$gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
if (-not $gpo) {
    throw "GPO '$GpoName' introuvable. Verifier que le TP05 est termine."
}

Set-GPLink -Name $GpoName -Target $TargetOu -LinkEnabled No

Write-Host "[CH04] Injection terminee." -ForegroundColor Yellow
Write-Host ""
Get-GPInheritance -Target $TargetOu
