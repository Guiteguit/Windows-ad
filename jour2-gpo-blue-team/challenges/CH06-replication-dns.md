# CH06 — Challenge réplication / DNS

Durée : 30 à 45 min

## Situation

`DC02` existe, mais il ne semble pas correctement utilisé. Certains tests DNS ou de réplication échouent.

Votre mission est d'identifier si le problème vient :

- de DNS ;
- de la promotion de `DC02` ;
- de la réplication AD ;
- de la découverte d'un contrôleur de domaine ;
- d'une configuration réseau incorrecte.

## Contraintes

- Ne rétrogradez pas `DC02` sans diagnostic.
- Ne modifiez pas `DC01` sans preuve.
- Ne changez pas plusieurs paramètres en même temps.
- Documentez la cause racine.

## Commandes utiles

Sur `DC02` :

```cmd
ipconfig /all
nslookup dc01.lab.local
nslookup dc02.lab.local
nltest /dsgetdc:lab.local
```

Sur un contrôleur de domaine :

```cmd
repadmin /replsummary
repadmin /showrepl
dcdiag
```

En PowerShell :

```powershell
Get-ADDomainController -Filter * | Select-Object HostName, IPv4Address, Site
```

## Méthode attendue

1. Vérifier l'adresse IP et le DNS de `DC02`.
2. Vérifier que `DC02` résout `DC01`.
3. Vérifier que `DC01` résout `DC02`.
4. Vérifier que `DC02` apparaît comme contrôleur de domaine.
5. Vérifier la réplication avec `repadmin`.
6. Lire les erreurs importantes de `dcdiag`.
7. Corriger la cause identifiée.
8. Prouver le retour à la normale.

## Résultat attendu après correction

```text
nslookup dc02.lab.local fonctionne
Get-ADDomainController liste DC01 et DC02
repadmin /replsummary ne montre pas d'échec critique
cause racine et correction documentées
```

## Livrable

Rédigez un rapport court avec :

- symptôme ;
- hypothèses ;
- commandes ;
- cause racine ;
- correction ;
- preuve de validation.

## Questions

1. Pourquoi DNS est-il encore plus critique avec plusieurs DC ?
2. Quelle commande donne une vue synthétique de la réplication ?
3. Pourquoi faut-il éviter de corriger plusieurs paramètres à la fois ?
