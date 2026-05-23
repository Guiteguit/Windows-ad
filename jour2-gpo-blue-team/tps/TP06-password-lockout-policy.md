# TP06 — Politique de mot de passe et verrouillage

Durée : 45 min

## Objectif

Configurer :

- mot de passe minimum 12 caractères ;
- complexité activée ;
- historique 10 ;
- verrouillage après 3 échecs ;
- durée de verrouillage 15 min.

## Vérification

```cmd
gpupdate /force
net accounts
```

## Test

Tenter 3 mauvais mots de passe avec `user.rh1`.

Puis :

```powershell
Search-ADAccount -LockedOut
Unlock-ADAccount -Identity "user.rh1"
```

## Questions

1. Pourquoi une politique trop stricte peut-elle créer un DoS ?
2. Pourquoi complexité seule ne suffit pas ?
