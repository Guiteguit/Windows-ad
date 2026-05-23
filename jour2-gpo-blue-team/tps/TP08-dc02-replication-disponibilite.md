# TP08 — DC02, réplication et disponibilité

Durée : 1h15

## Objectif

Ajouter un second contrôleur de domaine.

## Préparer DC02

DNS :

```text
192.168.56.10
```

Joindre domaine :

```powershell
Add-Computer -DomainName lab.local -Restart
```

Installer AD DS :

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

Promouvoir DC additionnel :

```powershell
Install-ADDSDomainController -DomainName "lab.local" -InstallDNS
```

## Vérifier

```powershell
Get-ADDomainController -Filter *
```

```cmd
dcdiag
repadmin /replsummary
repadmin /showrepl
nslookup dc02.lab.local
```

## Questions

1. Pourquoi au moins deux DC en production ?
2. Qu’est-ce que la réplication AD ?
3. Pourquoi AD Sites and Services est important ?
