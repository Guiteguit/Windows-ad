# TP02 — Jointure de SRV01 et CLIENT01 au domaine

Durée : 1h

## Objectif

Joindre `SRV01` et `CLIENT01` au domaine Active Directory `lab.local`.

À la fin du TP, vous devez être capable de prouver que :

- `SRV01` et `CLIENT01` utilisent `DC01` comme DNS ;
- les deux machines résolvent `lab.local` ;
- les deux machines sont membres du domaine ;
- les objets ordinateurs sont visibles dans Active Directory ;
- une session de domaine fonctionne.

## Prérequis

Avant de commencer :

- le TP01 est terminé ;
- `DC01` est démarré ;
- le domaine `lab.local` existe ;
- `nslookup dc01.lab.local` fonctionne depuis `DC01` ;
- vous connaissez un compte autorisé à joindre des machines au domaine, par exemple `LAB\Administrateur`.

## Rappel important

Pour joindre une machine à un domaine Active Directory, le poste doit utiliser le DNS du domaine.

Dans ce lab :

```text
DNS obligatoire pour SRV01 et CLIENT01 : 192.168.56.10
```

Un poste configuré avec `8.8.8.8`, `1.1.1.1` ou le DNS de la box Internet ne saura pas localiser les contrôleurs de domaine de `lab.local`.

## Travail demandé

### 1. Vérifier SRV01 avant jointure

Sur `SRV01`, vérifiez le nom :

```cmd
hostname
```

Si nécessaire :

```powershell
Rename-Computer -NewName "SRV01" -Restart
```

Vérifiez la carte réseau :

```powershell
Get-NetAdapter
```

Dans les commandes suivantes, remplacez `Ethernet` si votre interface porte un autre nom.

Configurez ou vérifiez l'adresse IP :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.20 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10
```

Vérifiez :

```cmd
ipconfig /all
```

### 2. Tester SRV01 avant jointure

Depuis `SRV01` :

```cmd
ping 192.168.56.10
nslookup dc01.lab.local
nslookup lab.local
nltest /dsgetdc:lab.local
```

Le test `nltest /dsgetdc:lab.local` doit retourner un contrôleur de domaine, normalement `DC01`.

Si `ping` fonctionne mais `nslookup` ou `nltest` échoue, le problème est probablement DNS.

### 3. Joindre SRV01 au domaine

Sur `SRV01` :

```powershell
Add-Computer -DomainName lab.local -Restart
```

Renseignez un compte autorisé, par exemple :

```text
LAB\Administrateur
```

La machine redémarre après la jointure.

### 4. Vérifier SRV01 après redémarrage

Après redémarrage, connectez-vous avec un compte du domaine.

Vérifiez :

```cmd
whoami
echo %logonserver%
nltest /dsgetdc:lab.local
```

Vous devez voir une session de type :

```text
lab\administrateur
```

ou un autre compte du domaine.

### 5. Répéter l'opération sur CLIENT01

Sur `CLIENT01`, vérifiez le nom :

```cmd
hostname
```

Si nécessaire :

```powershell
Rename-Computer -NewName "CLIENT01" -Restart
```

Configurez ou vérifiez le réseau :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.30 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10
```

Testez avant jointure :

```cmd
ping 192.168.56.10
nslookup dc01.lab.local
nltest /dsgetdc:lab.local
```

Joignez le domaine :

```powershell
Add-Computer -DomainName lab.local -Restart
```

Après redémarrage :

```cmd
whoami
echo %logonserver%
nltest /dsgetdc:lab.local
```

### 6. Vérifier les objets ordinateurs depuis DC01

Sur `DC01`, ouvrez PowerShell :

```powershell
Get-ADComputer SRV01 -Properties DistinguishedName
Get-ADComputer CLIENT01 -Properties DistinguishedName
```

Les deux objets doivent exister dans Active Directory. Par défaut, ils peuvent se trouver dans le conteneur `Computers`.

Dans les TP suivants, vous les déplacerez vers des OU plus propres.

### 7. Snapshot recommandé

Quand les deux machines sont jointes au domaine, prenez un snapshot des VM concernées selon la consigne du formateur.

Nom recommandé :

```text
SNAP_02_DOMAIN_JOINED
```

## Dépannage rapide

### Erreur : le domaine est introuvable

Vérifiez d'abord :

```cmd
ipconfig /all
nslookup dc01.lab.local
nltest /dsgetdc:lab.local
```

Cause fréquente : DNS configuré vers Internet au lieu de `192.168.56.10`.

### Erreur : accès refusé

Vérifiez :

- le compte utilisé pour joindre le domaine ;
- le mot de passe ;
- le format du compte : `LAB\Administrateur` ou `lab.local\Administrateur`.

### Erreur : nom de machine déjà existant

Vérifiez si un ancien objet ordinateur existe déjà :

```powershell
Get-ADComputer SRV01
Get-ADComputer CLIENT01
```

Ne supprimez pas un objet AD sans consigne du formateur.

## Erreurs fréquentes à éviter

- Joindre le domaine sans vérifier DNS avant.
- Garder le poste connecté à un mauvais réseau virtuel.
- Utiliser un compte local au lieu d'un compte autorisé du domaine.
- Oublier de redémarrer après renommage ou jointure.
- Confondre `CLIENT01\Administrateur` et `LAB\Administrateur`.

## Livrables

Déposez dans votre compte rendu :

- une capture de `ipconfig /all` sur `SRV01` et `CLIENT01` ;
- une capture de `nslookup dc01.lab.local` depuis `SRV01` ou `CLIENT01` ;
- une capture de `nltest /dsgetdc:lab.local` ;
- une capture de `whoami` après connexion au domaine ;
- une capture de `Get-ADComputer SRV01` et `Get-ADComputer CLIENT01` depuis `DC01`.

## Questions

1. Que se passe-t-il si `CLIENT01` utilise `8.8.8.8` comme DNS ?
2. Pourquoi un ping vers `DC01` ne suffit-il pas à valider la jointure domaine ?
3. Quelle différence faites-vous entre un compte local et un compte du domaine ?
4. Où sont placés par défaut les nouveaux objets ordinateurs dans Active Directory ?
