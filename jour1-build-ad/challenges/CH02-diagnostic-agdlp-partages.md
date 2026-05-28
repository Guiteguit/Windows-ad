# CH02 — Diagnostic AGDLP / partages

Durée : 45 min

## Situation

Le service RH signale une panne.

Depuis `CLIENT01`, avec le compte `LAB\user.rh1`, l'utilisateur ne peut plus écrire dans :

```text
\\SRV01\RH
```

Il indique que l'accès fonctionnait après le TP04.

## Objectif

Diagnostiquer une panne d'accès à un partage SMB protégé par le modèle AGDLP.

Vous devez déterminer si le problème vient :

- de l'appartenance de l'utilisateur aux groupes ;
- de l'imbrication AGDLP ;
- des permissions de partage SMB ;
- des permissions NTFS ;
- d'une session utilisateur non renouvelée.

## Contraintes

- Ne donnez pas de droits directement à `user.rh1`.
- Ne mettez pas `user.rh1` dans un groupe administrateur.
- Ne donnez pas `Tout le monde : Full Control`.
- Ne supprimez pas les partages pour les recréer sans diagnostic.
- Documentez les preuves avant et après correction.

## Commandes utiles

Sur `CLIENT01`, connecté avec `LAB\user.rh1` :

```cmd
whoami
whoami /groups
dir \\SRV01\RH
echo test > \\SRV01\RH\test-rh.txt
dir \\SRV01\Finance
```

Sur `SRV01` :

```powershell
Get-SmbShare
Get-SmbShareAccess -Name "RH"
icacls "C:\Shares\RH"
Get-SmbSession
```

Sur `DC01` :

```powershell
Get-ADPrincipalGroupMembership "user.rh1" | Select-Object Name
Get-ADGroupMember "GG_RH"
Get-ADGroupMember "DL_SHARE_RH_RW"
```

## Méthode attendue

1. Reproduire le symptôme avec `LAB\user.rh1`.
2. Vérifier les groupes présents dans le jeton utilisateur.
3. Vérifier les appartenances AD.
4. Vérifier les droits de partage SMB.
5. Vérifier les droits NTFS.
6. Identifier la rupture dans la chaîne AGDLP.
7. Corriger proprement.
8. Fermer puis rouvrir la session utilisateur si nécessaire.
9. Prouver que l'accès attendu fonctionne.

## Résultat attendu après correction

Avec `LAB\user.rh1` :

```text
\\SRV01\RH        écriture OK
\\SRV01\Finance   accès refusé
\\SRV01\Commun    lecture OK, écriture refusée
```

## Livrable

Rédigez un rapport d'incident avec :

- symptôme initial ;
- test de reproduction ;
- hypothèses ;
- commandes exécutées ;
- cause racine ;
- correction appliquée ;
- preuve de validation ;
- rappel du chemin AGDLP correct pour `user.rh1`.

## Questions

1. Quelle commande permet de voir les groupes réellement présents dans le jeton de session ?
2. Pourquoi une modification de groupe AD peut-elle nécessiter une nouvelle ouverture de session ?
3. Dans le modèle AGDLP, à quel type de groupe applique-t-on les permissions sur la ressource ?
4. Pourquoi un accès refusé peut-il venir soit du SMB, soit du NTFS ?
