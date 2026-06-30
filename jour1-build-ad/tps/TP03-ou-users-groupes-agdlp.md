# TP03 — OU, utilisateurs, groupes et AGDLP

Durée : 1h30

## Objectif

Construire une structure Active Directory propre et préparer le modèle d'habilitation AGDLP qui sera utilisé pour les partages de fichiers.

À la fin du TP, vous devez être capable de prouver que :

- les OU principales existent ;
- les comptes utilisateurs et administrateurs sont séparés ;
- les groupes globaux représentent des rôles métier ;
- les groupes Domain Local représentent des permissions sur des ressources ;
- les appartenances respectent le modèle AGDLP.

## Prérequis

Avant de commencer :

- `DC01` est contrôleur de domaine ;
- `SRV01` et `CLIENT01` sont joints au domaine ;
- vous êtes connecté sur `DC01` avec un compte administrateur du domaine ;
- la console `Utilisateurs et ordinateurs Active Directory` ou le module PowerShell AD est disponible.

## Rappel : AGDLP

AGDLP est un modèle d'attribution de droits :

```text
Accounts -> Global Groups -> Domain Local Groups -> Permissions
```

Dans ce TP :

- les utilisateurs sont placés dans des groupes globaux selon leur service ;
- les groupes globaux sont placés dans des groupes Domain Local selon les ressources ;
- les permissions NTFS/SMB seront données aux groupes Domain Local, pas directement aux utilisateurs.

Exemple :

```text
user.rh1 -> GG_RH -> DL_SHARE_RH_RW -> accès modification au partage RH
```

Cette méthode facilite l'audit, l'administration et le retrait des droits.

## Convention de nommage

Utilisez les conventions suivantes :

```text
GG_...          Groupe global
DL_...          Groupe Domain Local
adm....         Compte d'administration nominatif
svc....         Compte de service
user....        Compte utilisateur standard
```

## Travail demandé

### 1. Créer les OU principales

Sur `DC01`, ouvrez PowerShell en administrateur.

Créez les OU de premier niveau :

```powershell
New-ADOrganizationalUnit -Name "_Admins" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "_Serveurs" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "_Postes" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "_Utilisateurs" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "_Groupes" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "_GPO" -Path "DC=lab,DC=local"
```

Si une OU existe déjà, PowerShell affichera une erreur. Dans ce TP, l'important est que la structure finale soit correcte.

### 2. Créer les sous-OU

Sous `_Serveurs` :

```powershell
New-ADOrganizationalUnit -Name "File-Servers" -Path "OU=_Serveurs,DC=lab,DC=local"
```

Sous `_Postes` :

```powershell
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=_Postes,DC=lab,DC=local"
```

Sous `_Utilisateurs` :

```powershell
New-ADOrganizationalUnit -Name "IT" -Path "OU=_Utilisateurs,DC=lab,DC=local"
New-ADOrganizationalUnit -Name "RH" -Path "OU=_Utilisateurs,DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Finance" -Path "OU=_Utilisateurs,DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Direction" -Path "OU=_Utilisateurs,DC=lab,DC=local"
```

Sous `_Groupes` :

```powershell
New-ADOrganizationalUnit -Name "Global-Groups" -Path "OU=_Groupes,DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Domain-Local-Groups" -Path "OU=_Groupes,DC=lab,DC=local"
```

Structure attendue :

```text
_Admins
_Serveurs
  File-Servers
_Postes
  Workstations
_Utilisateurs
  IT
  RH
  Finance
  Direction
_Groupes
  Global-Groups
  Domain-Local-Groups
_GPO
```

### 3. Déplacer les ordinateurs dans les bonnes OU

Par défaut, les machines jointes au domaine sont souvent dans le conteneur `Computers`.

Déplacez `SRV01` :

```powershell
Get-ADComputer SRV01 | Move-ADObject -TargetPath "OU=File-Servers,OU=_Serveurs,DC=lab,DC=local"
```

Déplacez `CLIENT01` :

```powershell
Get-ADComputer CLIENT01 | Move-ADObject -TargetPath "OU=Workstations,OU=_Postes,DC=lab,DC=local"
```

Vérifiez :

```powershell
Get-ADComputer SRV01 -Properties DistinguishedName | Select-Object Name, DistinguishedName
Get-ADComputer CLIENT01 -Properties DistinguishedName | Select-Object Name, DistinguishedName
```

### 4. Créer les utilisateurs

Créez un mot de passe temporaire :

```powershell
$Password = ConvertTo-SecureString "P@ssw0rd-2026!" -AsPlainText -Force
```

Créez les comptes standards :

```powershell
New-ADUser -Name "user.it1" -SamAccountName "user.it1" -UserPrincipalName "user.it1@lab.local" -Path "OU=IT,OU=_Utilisateurs,DC=lab,DC=local" -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "user.rh1" -SamAccountName "user.rh1" -UserPrincipalName "user.rh1@lab.local" -Path "OU=RH,OU=_Utilisateurs,DC=lab,DC=local" -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "user.finance1" -SamAccountName "user.finance1" -UserPrincipalName "user.finance1@lab.local" -Path "OU=Finance,OU=_Utilisateurs,DC=lab,DC=local" -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "directeur" -SamAccountName "directeur" -UserPrincipalName "directeur@lab.local" -Path "OU=Direction,OU=_Utilisateurs,DC=lab,DC=local" -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $false
```

Créez les comptes spécifiques :

```powershell
New-ADUser -Name "adm.it1" -SamAccountName "adm.it1" -UserPrincipalName "adm.it1@lab.local" -Path "OU=_Admins,DC=lab,DC=local" -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "svc.backup" -SamAccountName "svc.backup" -UserPrincipalName "svc.backup@lab.local" -Path "OU=_Admins,DC=lab,DC=local" -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $false
```

Dans un environnement réel, un compte de service et un compte administrateur doivent avoir une stratégie de mot de passe et de délégation adaptée. Ici, le mot de passe commun est utilisé uniquement pour simplifier le lab.

### 5. Créer les groupes globaux

```powershell
New-ADGroup -Name "GG_IT" -SamAccountName "GG_IT" -GroupScope Global -GroupCategory Security -Path "OU=Global-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "GG_RH" -SamAccountName "GG_RH" -GroupScope Global -GroupCategory Security -Path "OU=Global-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "GG_FINANCE" -SamAccountName "GG_FINANCE" -GroupScope Global -GroupCategory Security -Path "OU=Global-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "GG_DIRECTION" -SamAccountName "GG_DIRECTION" -GroupScope Global -GroupCategory Security -Path "OU=Global-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "GG_ADMINS_SERVERS" -SamAccountName "GG_ADMINS_SERVERS" -GroupScope Global -GroupCategory Security -Path "OU=Global-Groups,OU=_Groupes,DC=lab,DC=local"
```

### 6. Ajouter les utilisateurs aux groupes globaux

```powershell
Add-ADGroupMember -Identity "GG_IT" -Members "user.it1"
Add-ADGroupMember -Identity "GG_RH" -Members "user.rh1"
Add-ADGroupMember -Identity "GG_FINANCE" -Members "user.finance1"
Add-ADGroupMember -Identity "GG_DIRECTION" -Members "directeur"
Add-ADGroupMember -Identity "GG_ADMINS_SERVERS" -Members "adm.it1"
```

### 7. Créer les groupes Domain Local

```powershell
New-ADGroup -Name "DL_SHARE_RH_RW" -SamAccountName "DL_SHARE_RH_RW" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domain-Local-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "DL_SHARE_FINANCE_RW" -SamAccountName "DL_SHARE_FINANCE_RW" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domain-Local-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "DL_SHARE_IT_RW" -SamAccountName "DL_SHARE_IT_RW" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domain-Local-Groups,OU=_Groupes,DC=lab,DC=local"
New-ADGroup -Name "DL_SHARE_COMMUN_RO" -SamAccountName "DL_SHARE_COMMUN_RO" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domain-Local-Groups,OU=_Groupes,DC=lab,DC=local"
```

### 8. Appliquer le modèle AGDLP

Ajoutez les groupes globaux dans les groupes Domain Local :

```powershell
Add-ADGroupMember -Identity "DL_SHARE_RH_RW" -Members "GG_RH"
Add-ADGroupMember -Identity "DL_SHARE_FINANCE_RW" -Members "GG_FINANCE"
Add-ADGroupMember -Identity "DL_SHARE_IT_RW" -Members "GG_IT"
Add-ADGroupMember -Identity "DL_SHARE_COMMUN_RO" -Members "GG_IT","GG_RH","GG_FINANCE","GG_DIRECTION"
```

Lecture attendue :

```text
user.rh1 est membre de GG_RH
GG_RH est membre de DL_SHARE_RH_RW
DL_SHARE_RH_RW recevra les permissions sur le dossier RH au TP04
```

### 9. Vérifier la structure

Vérifiez les groupes :

```powershell
Get-ADGroupMember "GG_RH"
Get-ADGroupMember "DL_SHARE_RH_RW"
Get-ADPrincipalGroupMembership "user.rh1" | Select-Object Name
```

Vérifiez l'ensemble des utilisateurs :

```powershell
Get-ADUser -Filter * -SearchBase "OU=_Utilisateurs,DC=lab,DC=local" | Select-Object Name, SamAccountName
```

Vérifiez les groupes créés :

```powershell
Get-ADGroup -Filter "Name -like 'GG_*'" | Select-Object Name, GroupScope
Get-ADGroup -Filter "Name -like 'DL_*'" | Select-Object Name, GroupScope
```

### 10. Snapshot recommandé

Nom recommandé :

```text
SNAP_02_DOMAIN_JOINED_STRUCTURE_READY
```

## Erreurs fréquentes à éviter

- Donner des permissions directement à un utilisateur.
- Mettre les utilisateurs directement dans les groupes Domain Local sans logique métier.
- Utiliser des groupes globaux pour porter directement des permissions NTFS.
- Mélanger comptes standards et comptes administrateurs.
- Laisser `SRV01` et `CLIENT01` dans le conteneur `Computers`.
- Créer les groupes au mauvais endroit sans convention de nommage.

## Livrables

Déposez dans votre compte rendu :

- une capture de la structure OU ;
- une capture de `Get-ADUser -Filter * -SearchBase "OU=_Utilisateurs,DC=lab,DC=local"` ;
- une capture de `Get-ADGroupMember "GG_RH"` ;
- une capture de `Get-ADGroupMember "DL_SHARE_RH_RW"` ;
- une capture de `Get-ADPrincipalGroupMembership "user.rh1" | Select-Object Name` ;
- une courte explication de la chaîne d'accès prévue pour `user.rh1` :
  `user.rh1 -> GG_RH -> DL_SHARE_RH_RW -> futur accès au dossier RH`.


## Questions

1. Pourquoi ne faut-il pas donner directement des droits à un utilisateur ?
2. Quelle différence faites-vous entre un groupe global et un groupe Domain Local ?
3. Pourquoi séparer un compte utilisateur standard et un compte administrateur ?
4. Pourquoi les objets ordinateurs doivent-ils être rangés dans des OU plutôt que laissés dans `Computers` ?
