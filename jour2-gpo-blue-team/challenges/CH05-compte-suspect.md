# CH05 — Challenge compte suspect

Durée : 30 à 45 min

## Situation

Un compte inconnu semble avoir été créé puis ajouté dans un groupe sensible.

Votre mission est de reconstituer ce qui s'est passé à partir des journaux de sécurité.

## Objectif

Retrouver :

- le compte créé ;
- le groupe modifié ;
- l'heure ;
- le compte source ;
- le risque ;
- la correction ;
- une mesure préventive.

## Event IDs utiles

```text
4720  création utilisateur
4728  ajout dans un groupe global
4729  retrait d'un groupe global
4738  modification utilisateur
4625  échec connexion
4624  connexion réussie
```

## Commandes utiles

Sur `DC01` :

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4720,4728,4729,4738,4625,4624} -MaxEvents 50 |
  Select-Object TimeCreated, Id, Message
```

Pour vérifier un compte :

```powershell
Get-ADUser backup-admin -Properties Enabled,Created,Modified,MemberOf
```

Pour vérifier un groupe sensible :

```powershell
Get-ADGroupMember "Admins du domaine"
```

## Méthode attendue

1. Filtrer les événements de sécurité.
2. Identifier le premier événement suspect.
3. Retrouver le compte cible.
4. Retrouver le groupe modifié.
5. Identifier le compte source qui a effectué l'action.
6. Évaluer le risque.
7. Proposer ou appliquer une correction.
8. Documenter la chronologie.

## Livrable

Rédigez une chronologie :

```text
Heure :
Event ID :
Compte source :
Compte cible :
Action :
Risque :
Preuve :
```

Ajoutez une conclusion courte :

- cause probable ;
- impact potentiel ;
- correction ;
- prévention.

## Questions

1. Pourquoi faut-il surveiller les groupes administrateurs ?
2. Quelle différence faites-vous entre un compte suspect et un compte compromis ?
3. Pourquoi une chronologie est-elle importante en investigation ?
