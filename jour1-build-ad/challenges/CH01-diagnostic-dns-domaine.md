# CH01 — Diagnostic DNS / domaine

Durée : 30 à 45 min

## Situation

Vous êtes appelé par un utilisateur de `CLIENT01`.

Depuis ce poste, l'utilisateur indique :

```text
Je n'arrive plus à accéder correctement au domaine lab.local.
Certaines commandes disent que le domaine est introuvable.
```

Votre mission est d'identifier la cause racine, de corriger proprement le problème et de prouver que le poste retrouve le domaine.

## Objectif

Diagnostiquer une panne de localisation du domaine Active Directory.

Vous devez distinguer :

- connectivité IP ;
- résolution DNS ;
- localisation d'un contrôleur de domaine ;
- ouverture de session domaine.

## Contraintes

- Ne réinstallez pas la machine.
- Ne sortez pas puis ne rejoignez pas le domaine sans avoir identifié la cause.
- Ne modifiez pas `DC01` tant que vous n'avez pas prouvé que le problème vient de lui.
- Documentez chaque commande utile.

## Commandes autorisées

Sur `CLIENT01` :

```cmd
hostname
whoami
ipconfig /all
ping 192.168.56.10
ping dc01.lab.local
nslookup lab.local
nslookup dc01.lab.local
nltest /dsgetdc:lab.local
echo %logonserver%
```

Sur `DC01`, uniquement si nécessaire :

```cmd
dcdiag /test:dns
nslookup dc01.lab.local
```

## Méthode attendue

1. Décrire le symptôme observé.
2. Vérifier la connectivité IP vers `DC01`.
3. Vérifier les paramètres IP et DNS de `CLIENT01`.
4. Tester la résolution DNS.
5. Tester la localisation d'un contrôleur de domaine.
6. Formuler une hypothèse.
7. Corriger uniquement le paramètre nécessaire.
8. Prouver la correction.

## Résultat attendu après correction

Depuis `CLIENT01` :

```cmd
nslookup dc01.lab.local
nltest /dsgetdc:lab.local
```

doivent retourner `DC01` ou `dc01.lab.local`.

## Livrable

Rédigez un rapport d'incident avec :

- symptôme initial ;
- hypothèses ;
- commandes exécutées ;
- résultats importants ;
- cause racine ;
- correction appliquée ;
- preuve de retour à la normale.

Utilisez le modèle :

```text
livrables/template-rapport-incident.md
```

## Questions

1. Pourquoi un ping vers `192.168.56.10` ne suffit-il pas à valider Active Directory ?
2. Quelle commande permet de demander à Windows quel contrôleur de domaine il trouve ?
3. Pourquoi un mauvais DNS casse-t-il souvent la jointure domaine, les GPO et les ouvertures de session ?
