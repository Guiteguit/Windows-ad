# TP09 — Maintenance, sauvegarde et dépannage AD

Durée : 45 min

## Objectif

Découvrir les commandes de maintenance Active Directory, comprendre la sauvegarde du System State et préparer une méthode de dépannage réutilisable.

À la fin du TP, vous devez être capable de :

- lancer un diagnostic AD de base ;
- lire un résumé de réplication ;
- expliquer l'intérêt du System State ;
- expliquer le principe de l'AD Recycle Bin ;
- structurer un diagnostic avant correction.

## 1. Diagnostic de santé AD

Sur un contrôleur de domaine :

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

## 2. Windows Server Backup

Sur `DC01`, installez la fonctionnalité :

```powershell
Install-WindowsFeature Windows-Server-Backup
```

Vérifiez :

```powershell
Get-WindowsFeature Windows-Server-Backup
```

## 3. System State Backup

Le System State contient notamment les composants nécessaires à la restauration d'un contrôleur de domaine.

Commande de démonstration :

```cmd
wbadmin start systemstatebackup -backupTarget:C: -quiet
```

Selon les contraintes VM, disque et temps, cette partie peut être démontrée par le formateur plutôt que réalisée par chaque étudiant.

Point de vigilance : en production, on ne sauvegarde pas sur le même disque que le système à protéger.

## 4. AD Recycle Bin

Vérifiez l'état de la corbeille Active Directory :

```powershell
Get-ADOptionalFeature -Filter 'Name -like "Recycle Bin Feature"'
```

Discussion :

- à quoi sert l'AD Recycle Bin ;
- ce qu'elle ne remplace pas ;
- pourquoi une sauvegarde reste nécessaire.

## 5. Méthode de dépannage attendue

Pour un incident AD, appliquez toujours cette méthode :

1. identifier le symptôme exact ;
2. vérifier DNS et connectivité ;
3. vérifier le contrôleur de domaine utilisé ;
4. lire les journaux pertinents ;
5. formuler une hypothèse ;
6. corriger un seul élément à la fois ;
7. prouver le retour à la normale ;
8. documenter.

## Livrables

Déposez dans votre compte rendu :

- une capture de `dcdiag` ou un résumé des erreurs ;
- une capture de `repadmin /replsummary` ;
- une capture de `Get-WindowsFeature Windows-Server-Backup` ;
- une réponse courte sur le rôle du System State ;
- une réponse courte sur l'AD Recycle Bin.

## Questions

1. Pourquoi sauvegarder le System State ?
2. Différence authoritative / non-authoritative restore ?
3. Pourquoi tester une restauration ?
4. Pourquoi une sauvegarde ne remplace-t-elle pas une bonne supervision ?
