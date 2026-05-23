# TP01 — Déploiement du domaine Active Directory

Durée : 1h15

## Objectif

Installer le premier contrôleur de domaine et créer `lab.local`.

## Renommer DC01

```powershell
Rename-Computer -NewName "DC01" -Restart
```

## Configurer IP et DNS

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.10 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
```

## Installer AD DS

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

## Promouvoir en contrôleur de domaine

```powershell
Install-ADDSForest `
-DomainName "lab.local" `
-DomainNetbiosName "LAB" `
-InstallDNS
```

## Vérifier

```powershell
Get-ADDomain
Get-ADForest
Get-ADDomainController
```

```cmd
nslookup dc01.lab.local
net share
```

Vous devez voir `SYSVOL` et `NETLOGON`.

## Questions

1. Pourquoi DNS est-il critique pour AD ?
2. À quoi servent SYSVOL et NETLOGON ?
3. Pourquoi faire un snapshot après cette étape ?
