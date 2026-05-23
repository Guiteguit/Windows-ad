# TP03 — OU, utilisateurs, groupes et AGDLP

Durée : 1h15

## Objectif

Créer une structure AD propre et appliquer le modèle AGDLP.

## OU attendues

```text
_Admins
_Serveurs/File-Servers
_Postes/Workstations
_Utilisateurs/IT/RH/Finance/Direction
_Groupes/Global-Groups/Domain-Local-Groups
```

## Utilisateurs

```text
user.it1
user.rh1
user.finance1
directeur
adm.it1
svc.backup
```

## Groupes globaux

```text
GG_IT
GG_RH
GG_FINANCE
GG_DIRECTION
GG_ADMINS_SERVERS
```

## Groupes Domain Local

```text
DL_SHARE_RH_RW
DL_SHARE_FINANCE_RW
DL_SHARE_IT_RW
DL_SHARE_COMMUN_RO
```

## AGDLP attendu

```text
user.rh1 -> GG_RH -> DL_SHARE_RH_RW -> Permission RH
```

## Vérifications

```powershell
Get-ADGroupMember "GG_RH"
Get-ADGroupMember "DL_SHARE_RH_RW"
Get-ADPrincipalGroupMembership "user.rh1" | Select-Object Name
```

## Questions

1. Pourquoi ne pas donner directement des droits à un utilisateur ?
2. Différence entre groupe global et groupe Domain Local ?
3. Pourquoi séparer compte utilisateur et compte admin ?
