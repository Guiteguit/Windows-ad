# CH04 — Challenge GPO non appliquée

Durée : 30 à 45 min

## Situation

La GPO `GPO_SECURITE_POSTES` existe, mais les restrictions ne semblent pas s'appliquer sur `CLIENT01`.

Un utilisateur standard peut encore ouvrir certains outils qui devraient être bloqués.

## Objectif

Diagnostiquer une GPO non appliquée sans recréer toute la configuration.

Vous devez distinguer :

- mauvais placement de l'objet ordinateur ;
- lien GPO absent ou désactivé ;
- filtrage de sécurité incorrect ;
- héritage bloqué ;
- confusion Configuration utilisateur (User Configuration) / Configuration ordinateur (Computer Configuration) ;
- boucle de rappel (loopback) absente ;
- problème DNS ou de jointure domaine.

## Contraintes

- Ne recréez pas la GPO sans diagnostic.
- Ne déplacez pas tous les objets AD au hasard.
- Ne désactivez pas les autres GPO sans preuve.
- Documentez les preuves avant correction.

## Commandes utiles

Sur `CLIENT01` :

```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\rapport-gpo.html
rsop.msc
nltest /dsgetdc:lab.local
```

Sur `DC01` :

```powershell
Get-ADComputer CLIENT01 -Properties DistinguishedName | Select-Object Name, DistinguishedName
Get-GPO -Name "GPO_SECURITE_POSTES"
Get-GPInheritance -Target "OU=Workstations,OU=_Postes,DC=lab,DC=local"
```

## Méthode attendue

1. Reproduire le symptôme.
2. Vérifier que `CLIENT01` est dans la bonne OU.
3. Vérifier que la GPO est liée à cette OU.
4. Vérifier que le lien est actif.
5. Vérifier le filtrage de sécurité.
6. Vérifier si les paramètres sont côté utilisateur ou ordinateur (User / Computer).
7. Vérifier la boucle de rappel (loopback) si des paramètres utilisateur sont attendus.
8. Corriger uniquement la cause identifiée.
9. Prouver l'application avec `gpresult`.

## Résultat attendu après correction

```text
GPO_SECURITE_POSTES visible dans gpresult
restriction testée et appliquée sur CLIENT01
cause racine documentée
```

## Livrable

Rédigez un rapport d'incident avec :

- symptôme initial ;
- hypothèses ;
- commandes exécutées ;
- cause racine ;
- correction ;
- preuve de validation.

## Questions

1. Pourquoi `gpupdate /force` ne garantit-il pas qu'une GPO est applicable ?
2. Quelle commande permet de voir les GPO réellement appliquées ?
3. Pourquoi la boucle de rappel (loopback) est-elle souvent nécessaire dans une OU de postes ?
