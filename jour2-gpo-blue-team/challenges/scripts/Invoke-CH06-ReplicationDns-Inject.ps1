#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string]$InterfaceAlias = "Ethernet0",

    [string]$BrokenDns = "192.168.56.254"
)

$ErrorActionPreference = "Stop"

$adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue
if (-not $adapter) {
    throw "Interface '$InterfaceAlias' introuvable. Utiliser -InterfaceAlias avec le nom correct."
}

Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $BrokenDns
Clear-DnsClientCache

Write-Host "[CH06] Injection terminee." -ForegroundColor Yellow
Write-Host ""
Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4
