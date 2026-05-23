# CH04 — Challenge GPO non appliquée

La GPO `GPO_SECURITE_POSTES` existe mais ne s’applique pas.

## Pistes

- mauvaise OU ;
- lien GPO désactivé ;
- filtrage sécurité ;
- héritage bloqué ;
- User vs Computer ;
- loopback absent ;
- DNS.

## Commandes

```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\rapport-gpo.html
rsop.msc
```
