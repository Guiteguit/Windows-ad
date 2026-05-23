# TP05 — GPO de sécurisation des postes

Durée : 1h15

## Objectif

Créer `GPO_SECURITE_POSTES` et la lier à :

```text
OU=Workstations,OU=_Postes,DC=lab,DC=local
```

## Paramètres

- bannière de connexion ;
- verrouillage session ;
- interdiction panneau de configuration ;
- blocage `cmd.exe` ;
- blocage `regedit.exe` ;
- blocage disques amovibles ;
- pare-feu Windows ;
- audit logon success/failure.

## Commandes de validation

```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\rapport-gpo.html
rsop.msc
```

## Point clé

Pour appliquer des paramètres User Configuration via une OU de postes, activer le loopback processing en mode Merge.

## Questions

1. Différence Computer Configuration / User Configuration ?
2. À quoi sert le loopback ?
3. Pourquoi tester sur une OU pilote ?
