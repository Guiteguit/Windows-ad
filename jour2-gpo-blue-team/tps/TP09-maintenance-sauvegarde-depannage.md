# TP09 — Maintenance, sauvegarde et dépannage AD

Durée : 45 min à 1h15 selon les performances disque

## Objectif

Découvrir les commandes de maintenance Active Directory, comprendre la sauvegarde du System State et préparer une méthode de dépannage réutilisable.

À la fin du TP, vous devez être capable de :

- lancer un diagnostic AD de base ;
- lire un résumé de réplication ;
- expliquer l'intérêt du System State ;
- préparer un disque de sauvegarde dédié ;
- lancer une sauvegarde System State ;
- expliquer le principe de l'AD Recycle Bin ;
- structurer un diagnostic avant correction.

## Point important : pourquoi ne pas sauvegarder vers C: ?

Une sauvegarde System State inclut des éléments présents sur le disque système, notamment `C:` et des partitions système comme EFI ou Recovery.

La commande suivante peut donc échouer :

```cmd
wbadmin start systemstatebackup -backupTarget:C: -quiet
```

Erreur typique :

```text
L'emplacement de stockage de sauvegarde n'est pas valide.
Vous ne pouvez pas utiliser un volume inclus dans la sauvegarde comme emplacement de stockage.
```

C'est logique : Windows refuse de sauvegarder l'état du système vers un volume qui fait lui-même partie de la sauvegarde. Dans ce TP, vous allez donc ajouter un disque dédié à la sauvegarde.

En production, on ne sauvegarde pas sur le même disque physique que le système à protéger. Pour le lab, un second disque virtuel est suffisant pour comprendre la méthode.

## Prérequis

Avant de commencer :

- `DC01` est démarré ;
- vous êtes connecté avec un compte administrateur ;
- la VM `DC01` peut être arrêtée quelques minutes pour ajouter un disque ;
- l'hôte dispose d'au moins 30 Go d'espace disque disponible.

## 1. Diagnostic de santé AD

Sur `DC01` :

```cmd
dcdiag
repadmin /replsummary
repadmin /showrepl
```

Notez :

```text
erreurs critiques
contrôleur concerné
partenaire de réplication
horodatage du dernier succès
```

Si vous observez des erreurs, ne les corrigez pas au hasard. Documentez d'abord le symptôme, la commande et l'erreur.

## 2. Ajouter un disque de sauvegarde dans VMware Workstation

Sur l'hôte, dans VMware Workstation :

1. arrêtez proprement la VM `DC01` ;
2. sélectionnez la VM `DC01` ;
3. ouvrez `VM > Settings` ;
4. cliquez sur `Add...` ;
5. choisissez `Hard Disk` ;
6. gardez le type recommandé par VMware, par exemple `SCSI` ;
7. choisissez `Create a new virtual disk` ;
8. taille recommandée :

```text
30 GB
```

9. choisissez `Store virtual disk as a single file` ou `Split virtual disk into multiple files` selon vos habitudes ;
10. nommez le disque, par exemple :

```text
DC01-backup.vmdk
```

11. validez, puis redémarrez `DC01`.

Remarque : 20 Go peuvent suffire dans certains labs, mais 30 Go évitent les mauvaises surprises selon la taille du System State.

## 3. Initialiser et formater le disque dans Windows

Vous pouvez utiliser la méthode graphique ou PowerShell.

### Méthode graphique : Gestion des disques

Sur `DC01` :

1. ouvrez le menu démarrer ;
2. cherchez `Gestion des disques` ;
3. ouvrez `Créer et formater des partitions de disque dur` ;
4. si Windows propose d'initialiser le nouveau disque, choisissez :

```text
GPT
```

5. repérez le nouveau disque non alloué d'environ 30 Go ;
6. clic droit sur l'espace non alloué ;
7. choisissez `Nouveau volume simple` ;
8. utilisez toute la taille disponible ;
9. attribuez la lettre :

```text
E:
```

10. formatez en :

```text
Système de fichiers : NTFS
Nom du volume       : BACKUP
Formatage rapide    : oui
```

11. validez et vérifiez que le volume `E:` apparaît dans l'explorateur.

### Méthode PowerShell

Sur `DC01`, ouvrez PowerShell en administrateur.

Affichez les disques :

```powershell
Get-Disk
```

Repérez le nouveau disque. Il doit généralement apparaître avec :

```text
PartitionStyle : RAW
```

Attention : vérifiez bien que le disque RAW correspond au nouveau disque de sauvegarde avant de l'initialiser. Ne formatez jamais un disque sans avoir identifié sa taille et son numéro.

Initialisez et formatez le disque en NTFS avec la lettre `E:` :

```powershell
$BackupDisk = Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Sort-Object Number | Select-Object -First 1
$BackupDisk | Initialize-Disk -PartitionStyle GPT
$Partition = $BackupDisk | New-Partition -DriveLetter E -UseMaximumSize
$Partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel "BACKUP" -Confirm:$false
```

Vérifiez :

```powershell
Get-Volume -DriveLetter E
Get-PSDrive E
```

Résultat attendu :

```text
DriveLetter : E
FileSystem  : NTFS
Label       : BACKUP
```

Si `E:` est déjà utilisé, choisissez une autre lettre disponible, par exemple `F:`, puis adaptez les commandes suivantes.

## 4. Installer Windows Server Backup

Sur `DC01`, installez la fonctionnalité :

```powershell
Install-WindowsFeature Windows-Server-Backup
```

Vérifiez :

```powershell
Get-WindowsFeature Windows-Server-Backup
```

La fonctionnalité doit apparaître comme installée.

## 5. Lancer une sauvegarde System State

Le System State contient notamment les composants nécessaires à la restauration d'un contrôleur de domaine :

```text
base Active Directory
SYSVOL
registre
fichiers de démarrage
services système critiques
configuration COM+
certains composants liés aux rôles installés
```

Lancez la sauvegarde vers le disque dédié :

```cmd
wbadmin start systemstatebackup -backupTarget:E: -quiet
```

La sauvegarde peut prendre plusieurs minutes.

Vérifiez ensuite les sauvegardes disponibles :

```cmd
wbadmin get versions -backupTarget:E:
```

Résultat attendu :

```text
une version de sauvegarde est listée
la sauvegarde est stockée sur E:
```

## 6. Vérifier le contenu du disque de sauvegarde

Sur `DC01` :

```powershell
Get-ChildItem E:\
```

Vous devez retrouver un dossier de sauvegarde Windows, généralement :

```text
WindowsImageBackup
```

Ne modifiez pas manuellement son contenu.

## 7. AD Recycle Bin

Vérifiez l'état de la corbeille Active Directory :

```powershell
Get-ADOptionalFeature -Filter 'Name -like "Recycle Bin Feature"'
```

Discussion :

- à quoi sert l'AD Recycle Bin ;
- ce qu'elle ne remplace pas ;
- pourquoi une sauvegarde reste nécessaire.

À retenir :

```text
AD Recycle Bin aide à restaurer certains objets AD supprimés.
System State Backup aide à restaurer un contrôleur de domaine ou l'état AD.
Les deux mécanismes sont complémentaires.
```

## 8. Méthode de dépannage attendue

Pour un incident AD, appliquez toujours cette méthode :

1. identifier le symptôme exact ;
2. vérifier DNS et connectivité ;
3. vérifier le contrôleur de domaine utilisé ;
4. lire les journaux pertinents ;
5. formuler une hypothèse ;
6. corriger un seul élément à la fois ;
7. prouver le retour à la normale ;
8. documenter.

## Dépannage rapide

### `backupTarget:C:` est refusé

C'est normal. `C:` est inclus dans le périmètre de la sauvegarde System State. Utilisez le disque dédié `E:`.

### Aucun disque RAW n'apparaît

Vérifiez :

- que le disque a bien été ajouté dans VMware Workstation ;
- que la VM a été redémarrée ;
- que vous êtes bien sur `DC01` ;
- que le disque n'a pas déjà été initialisé.

### La sauvegarde manque d'espace

Vérifiez :

```powershell
Get-Volume -DriveLetter E
```

Si l'espace est insuffisant, augmentez la taille du disque de sauvegarde ou ajoutez un nouveau disque.

### `wbadmin` n'est pas reconnu

Vérifiez que la fonctionnalité est installée :

```powershell
Get-WindowsFeature Windows-Server-Backup
```

## Livrables

Déposez dans votre compte rendu :

- une capture de `dcdiag` ou un résumé des erreurs ;
- une capture de `repadmin /replsummary` ;
- une capture montrant le disque `E:` avec le label `BACKUP` ;
- une capture de `Get-WindowsFeature Windows-Server-Backup` ;
- une capture de la commande `wbadmin start systemstatebackup -backupTarget:E: -quiet` terminée ;
- une capture de `wbadmin get versions -backupTarget:E:` ;
- une réponse courte sur le rôle du System State ;
- une réponse courte sur l'AD Recycle Bin.

## Questions

1. Pourquoi `wbadmin` refuse-t-il de sauvegarder le System State vers `C:` ?
2. Pourquoi sauvegarder le System State ?
3. Différence authoritative / non-authoritative restore ?
4. Pourquoi tester une restauration ?
5. Pourquoi une sauvegarde ne remplace-t-elle pas une bonne supervision ?
