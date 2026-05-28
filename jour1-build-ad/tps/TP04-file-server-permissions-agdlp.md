# TP04 — Serveur de fichiers et permissions AGDLP

Durée : 1h30

## Objectif

Configurer `SRV01` comme serveur de fichiers et appliquer des permissions cohérentes avec le modèle AGDLP préparé au TP03.

À la fin du TP, vous devez être capable de prouver que :

- `SRV01` héberge plusieurs partages SMB ;
- les permissions de partage sont cohérentes ;
- les permissions NTFS sont appliquées sur les bons groupes Domain Local ;
- les utilisateurs accèdent uniquement aux dossiers autorisés ;
- les refus d'accès attendus sont documentés.

## Prérequis

Avant de commencer :

- `DC01` est démarré ;
- `SRV01` est joint au domaine `lab.local` ;
- les utilisateurs et groupes du TP03 existent ;
- `SRV01` utilise `192.168.56.10` comme DNS ;
- vous êtes connecté sur `SRV01` avec un compte administrateur du domaine.

## Rappel : permissions de partage et permissions NTFS

Pour accéder à un dossier partagé Windows, deux couches de permissions s'appliquent :

```text
Permission effective = permission SMB la plus restrictive + permission NTFS la plus restrictive
```

Dans ce TP :

- les permissions SMB exposent les partages réseau ;
- les permissions NTFS protègent réellement les dossiers ;
- les droits sont donnés aux groupes Domain Local ;
- les utilisateurs ne reçoivent pas de droits directs.

Exemple AGDLP :

```text
user.rh1 -> GG_RH -> DL_SHARE_RH_RW -> permission NTFS sur C:\Shares\RH
```

## Plan des partages

```text
Partage    Chemin local          Accès attendu
Commun     C:\Shares\Commun      Tous les services en lecture
RH         C:\Shares\RH          RH en modification
Finance    C:\Shares\Finance     Finance en modification
IT         C:\Shares\IT          IT en modification
```

## Travail demandé

### 1. Vérifier SRV01

Sur `SRV01` :

```cmd
hostname
whoami
ipconfig /all
nltest /dsgetdc:lab.local
```

Contrôlez que :

- le nom est `SRV01` ;
- la session est une session du domaine ;
- le DNS pointe vers `192.168.56.10` ;
- `nltest` trouve `DC01`.

### 2. Installer le rôle serveur de fichiers

```powershell
Install-WindowsFeature FS-FileServer -IncludeManagementTools
```

Vérifiez :

```powershell
Get-WindowsFeature FS-FileServer
```

### 3. Créer l'arborescence locale

```powershell
New-Item -Path "C:\Shares" -ItemType Directory -Force
New-Item -Path "C:\Shares\Commun" -ItemType Directory -Force
New-Item -Path "C:\Shares\RH" -ItemType Directory -Force
New-Item -Path "C:\Shares\Finance" -ItemType Directory -Force
New-Item -Path "C:\Shares\IT" -ItemType Directory -Force
```

Vérifiez :

```powershell
Get-ChildItem "C:\Shares"
```

### 4. Créer les partages SMB

Créez les partages :

```powershell
New-SmbShare -Name "Commun" -Path "C:\Shares\Commun" -FullAccess "LAB\Admins du domaine" -ReadAccess "LAB\DL_SHARE_COMMUN_RO"
New-SmbShare -Name "RH" -Path "C:\Shares\RH" -FullAccess "LAB\Admins du domaine" -ChangeAccess "LAB\DL_SHARE_RH_RW"
New-SmbShare -Name "Finance" -Path "C:\Shares\Finance" -FullAccess "LAB\Admins du domaine" -ChangeAccess "LAB\DL_SHARE_FINANCE_RW"
New-SmbShare -Name "IT" -Path "C:\Shares\IT" -FullAccess "LAB\Admins du domaine" -ChangeAccess "LAB\DL_SHARE_IT_RW"
```

Vérifiez :

```powershell
Get-SmbShare
Get-SmbShareAccess -Name "RH"
Get-SmbShareAccess -Name "Finance"
Get-SmbShareAccess -Name "IT"
Get-SmbShareAccess -Name "Commun"
```

Remarque : dans un environnement Windows Server en français, le groupe intégré est `LAB\Admins du domaine`.

### 5. Appliquer les permissions NTFS

Supprimez l'héritage puis appliquez les droits attendus.

Pour `RH` :

```powershell
icacls "C:\Shares\RH" /inheritance:r
icacls "C:\Shares\RH" /grant "LAB\Admins du domaine:(OI)(CI)(F)"
icacls "C:\Shares\RH" /grant "SYSTEM:(OI)(CI)(F)"
icacls "C:\Shares\RH" /grant "LAB\DL_SHARE_RH_RW:(OI)(CI)(M)"
```

Pour `Finance` :

```powershell
icacls "C:\Shares\Finance" /inheritance:r
icacls "C:\Shares\Finance" /grant "LAB\Admins du domaine:(OI)(CI)(F)"
icacls "C:\Shares\Finance" /grant "SYSTEM:(OI)(CI)(F)"
icacls "C:\Shares\Finance" /grant "LAB\DL_SHARE_FINANCE_RW:(OI)(CI)(M)"
```

Pour `IT` :

```powershell
icacls "C:\Shares\IT" /inheritance:r
icacls "C:\Shares\IT" /grant "LAB\Admins du domaine:(OI)(CI)(F)"
icacls "C:\Shares\IT" /grant "SYSTEM:(OI)(CI)(F)"
icacls "C:\Shares\IT" /grant "LAB\DL_SHARE_IT_RW:(OI)(CI)(M)"
```

Pour `Commun` :

```powershell
icacls "C:\Shares\Commun" /inheritance:r
icacls "C:\Shares\Commun" /grant "LAB\Admins du domaine:(OI)(CI)(F)"
icacls "C:\Shares\Commun" /grant "SYSTEM:(OI)(CI)(F)"
icacls "C:\Shares\Commun" /grant "LAB\DL_SHARE_COMMUN_RO:(OI)(CI)(RX)"
```

Signification rapide :

```text
F   Full control
M   Modify
RX  Read and execute
OI  Object inherit, appliqué aux fichiers enfants
CI  Container inherit, appliqué aux dossiers enfants
```

### 6. Vérifier les ACL NTFS

```powershell
icacls "C:\Shares\RH"
icacls "C:\Shares\Finance"
icacls "C:\Shares\IT"
icacls "C:\Shares\Commun"
```

Vous devez retrouver les groupes `DL_SHARE_...` correspondants.

### 7. Tester depuis CLIENT01

Sur `CLIENT01`, connectez-vous avec :

```text
LAB\user.rh1
```

Testez :

```text
\\SRV01\RH
\\SRV01\Finance
\\SRV01\Commun
```

Résultat attendu pour `LAB\user.rh1` :

```text
\\SRV01\RH        accès OK, création de fichier OK
\\SRV01\Finance   accès refusé
\\SRV01\Commun    lecture OK, écriture refusée
```

Créez un fichier de test dans `RH` :

```text
test-rh.txt
```

Essayez ensuite de créer un fichier dans `Commun`. L'opération doit être refusée pour `user.rh1`.

### 8. Tester avec un autre profil

Déconnectez-vous puis connectez-vous avec :

```text
LAB\user.finance1
```

Résultat attendu :

```text
\\SRV01\Finance   accès OK, création de fichier OK
\\SRV01\RH        accès refusé
\\SRV01\Commun    lecture OK, écriture refusée
```

### 9. Vérifier les sessions et fichiers ouverts

Sur `SRV01` :

```powershell
Get-SmbSession
Get-SmbOpenFile
```

Ces commandes permettent d'observer les connexions SMB actives.

### 10. Snapshot recommandé

Nom recommandé :

```text
SNAP_03_FILESERVER_AGDLP_READY
```

## Dépannage rapide

### L'utilisateur a encore accès après modification des groupes

Fermez la session puis reconnectez-vous. Les appartenances aux groupes sont chargées dans le jeton de sécurité à l'ouverture de session.

Vous pouvez vérifier les groupes de l'utilisateur avec :

```cmd
whoami /groups
```

### Le partage est visible mais l'accès est refusé

Vérifiez les deux couches :

```powershell
Get-SmbShareAccess -Name "RH"
icacls "C:\Shares\RH"
```

### `\\SRV01\RH` ne répond pas

Vérifiez :

```cmd
ping SRV01
nslookup SRV01.lab.local
```

Si le nom `SRV01` ne se résout pas, vérifiez DNS et la jointure domaine.

### Un utilisateur peut écrire dans Commun

Vérifiez que `DL_SHARE_COMMUN_RO` a uniquement `RX` en NTFS et `ReadAccess` côté SMB.

## Erreurs fréquentes à éviter

- Donner les droits NTFS directement à `user.rh1`.
- Oublier de supprimer l'héritage NTFS.
- Donner `FullAccess` côté SMB à tout le monde.
- Tester avec un compte administrateur au lieu d'un utilisateur standard.
- Modifier les groupes sans fermer puis rouvrir la session utilisateur.
- Confondre refus attendu et erreur de configuration.

## Livrables

Déposez dans votre compte rendu :

- une capture de `Get-SmbShare` ;
- une capture de `Get-SmbShareAccess -Name "RH"` ;
- une capture de `icacls "C:\Shares\RH"` ;
- une capture de `icacls "C:\Shares\Commun"` ;
- une capture montrant `user.rh1` capable d'écrire dans `\\SRV01\RH` ;
- une capture montrant `user.rh1` refusé sur `\\SRV01\Finance` ;
- une capture montrant `user.rh1` en lecture seule sur `\\SRV01\Commun` ;
- une courte explication du chemin AGDLP utilisé pour le dossier RH.

## Questions

1. Quelle différence faites-vous entre permission de partage SMB et permission NTFS ?
2. Pourquoi les permissions sont-elles appliquées aux groupes `DL_SHARE_...` plutôt qu'aux groupes `GG_...` ?
3. Pourquoi faut-il fermer puis rouvrir la session après une modification d'appartenance à un groupe ?
4. Pourquoi faut-il tester avec un utilisateur standard plutôt qu'avec un administrateur du domaine ?
