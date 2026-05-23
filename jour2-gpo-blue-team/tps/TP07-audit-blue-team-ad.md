# TP07 — Audit AD et investigation Blue Team

Durée : 1h30

## Objectif

Activer l’audit, générer des événements sensibles et produire une chronologie.

## GPO

Créer `GPO_AUDIT_AD`, liée au domaine.

Activer en Success and Failure :

```text
Account Logon
Account Management
Logon/Logoff
Policy Change
```

## Vérification

```cmd
gpupdate /force
auditpol /get /category:*
```

## Générer un compte suspect

```powershell
$Password = ConvertTo-SecureString "P@ssw0rd-Suspect-2026!" -AsPlainText -Force
New-ADUser -Name "backup-admin" -SamAccountName "backup-admin" -UserPrincipalName "backup-admin@lab.local" -Path "OU=_Admins,DC=lab,DC=local" -AccountPassword $Password -Enabled $true
Add-ADGroupMember -Identity "Admins du domaine" -Members "backup-admin"
```

## Event IDs

```text
4720 création utilisateur
4728 ajout dans groupe global
4625 échec connexion
4738 modification utilisateur
4729 retrait groupe
```

## Nettoyage

```powershell
Remove-ADGroupMember -Identity "Admins du domaine" -Members "backup-admin" -Confirm:$false
Disable-ADAccount -Identity "backup-admin"
```

## Livrable

Rapport d’investigation : chronologie, comptes, groupes, Event IDs, risque, actions correctives, prévention.
