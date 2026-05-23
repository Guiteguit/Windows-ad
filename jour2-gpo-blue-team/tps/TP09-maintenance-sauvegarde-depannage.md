# TP09 — Maintenance, sauvegarde et dépannage AD

Durée : 45 min

## Diagnostic

```cmd
dcdiag
repadmin /replsummary
repadmin /showrepl
```

## Windows Server Backup

```powershell
Install-WindowsFeature Windows-Server-Backup
```

## System State Backup

```cmd
wbadmin start systemstatebackup -backupTarget:C: -quiet
```

Selon les contraintes VM, cette partie peut être démontrée.

## AD Recycle Bin

```powershell
Get-ADOptionalFeature -Filter 'Name -like "Recycle Bin Feature"'
```

## Questions

1. Pourquoi sauvegarder le System State ?
2. Différence authoritative / non-authoritative restore ?
3. Pourquoi tester une restauration ?
