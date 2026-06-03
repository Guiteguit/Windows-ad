# TP01 — Déploiement du domaine Active Directory

Durée : 1h15

## Objectif

Installer le premier contrôleur de domaine du lab et créer la forêt Active Directory `lab.local`.

À la fin du TP, vous devez être capable de prouver que :

- `DC01` possède une IP fixe ;
- le rôle AD DS est installé ;
- le domaine `lab.local` existe ;
- `DC01` assure le rôle DNS du domaine ;
- les partages `SYSVOL` et `NETLOGON` sont présents.

## Prérequis

Avant de commencer :

- le TP00 est terminé ;
- la VM `DC01` est démarrée ;
- `DC01` est sur le réseau `192.168.56.0/24` ;
- aucun autre contrôleur de domaine n'existe dans le lab ;
- vous utilisez une session administrateur local sur `DC01`.

## Rappel

Dans ce lab :

```text
Domaine DNS : lab.local
NetBIOS     : LAB
DC01        : 192.168.56.10
```

Active Directory utilise DNS pour localiser les contrôleurs de domaine, les services Kerberos, LDAP, les catalogues globaux et les ressources du domaine. Une configuration DNS incorrecte est une cause classique d'échec de jointure au domaine ou d'application des GPO.

## Travail demandé

### 1. Vérifier ou renommer la machine

Sur `DC01` :

```cmd
hostname
```

Si le nom n'est pas `DC01`, renommez la machine :

```powershell
Rename-Computer -NewName "DC01" -Restart
```

Après redémarrage, reconnectez-vous et vérifiez de nouveau :

```cmd
hostname
```

### 2. Identifier l'interface réseau

```powershell
Get-NetAdapter
```

Repérez l'interface connectée au réseau du lab. Dans les exemples suivants, elle est appelée `Ethernet`. Adaptez le nom si nécessaire.

### 3. Configurer l'adresse IP fixe

Vérifiez la configuration actuelle :

```powershell
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4
```

Configurez l'adresse IP attendue si elle n'est pas déjà présente :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.10 -PrefixLength 24
```

Configurez le DNS de `DC01` vers lui-même :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
```

Vérifiez :

```cmd
ipconfig /all
```

### 4. Installer le rôle AD DS

Sur `DC01`, ouvrez PowerShell en administrateur :

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

Vérifiez l'installation :

```powershell
Get-WindowsFeature AD-Domain-Services
```

La colonne `Install State` doit indiquer `Installed`.

### 5. Promouvoir DC01 en contrôleur de domaine

Créez la forêt `lab.local` :

```powershell
Install-ADDSForest `
  -DomainName "lab.local" `
  -DomainNetbiosName "LAB" `
  -InstallDNS
```

L'assistant vous demande un mot de passe DSRM, c'est-à-dire le mot de passe du mode de restauration des services d'annuaire.

Important :

- notez ce mot de passe dans votre espace de travail personnel ;
- ne le confondez pas avec un mot de passe utilisateur du domaine ;
- la machine redémarre automatiquement à la fin de la promotion.

### 6. Se reconnecter avec un compte du domaine

Après redémarrage, connectez-vous avec le compte administrateur du domaine :

```text
LAB\Administrateur
```

ou :

```text
lab.local\Administrateur
```

Vérifiez le contexte de session :

```cmd
whoami
echo %logonserver%
```

### 7. Vérifier Active Directory

Dans PowerShell :

```powershell
Get-ADDomain
Get-ADForest
Get-ADDomainController
```

Vous devez retrouver :

```text
DNSRoot        : lab.local
NetBIOSName    : LAB
DomainMode     : ...
ForestMode     : ...
HostName       : DC01.lab.local
```

### 8. Vérifier DNS

Depuis `DC01` :

```cmd
nslookup dc01.lab.local
nslookup lab.local
```

Vous devez obtenir une réponse associée à `192.168.56.10`.

### Point de compréhension : les enregistrements DNS SRV

Active Directory ne se contente pas de résoudre un nom comme `dc01.lab.local`. Les machines du domaine doivent aussi découvrir quels serveurs fournissent certains services AD.

Pour cela, AD publie des enregistrements DNS de type `SRV`.

Un enregistrement `SRV` indique :

```text
service disponible
protocole utilisé
domaine concerné
serveur qui fournit le service
port utilisé
priorité / poids
```

Exemples de services recherchés par les postes et serveurs membres :

```text
LDAP      pour interroger l'annuaire Active Directory
Kerberos  pour l'authentification
GC        pour le catalogue global
```

Concrètement, lorsqu'un poste veut joindre le domaine ou appliquer des GPO, il demande au DNS :

```text
Quel contrôleur de domaine peut répondre pour lab.local ?
```

Si les enregistrements `SRV` sont absents ou incorrects, le domaine peut exister mais les clients ne savent pas correctement trouver les contrôleurs de domaine. Cela provoque souvent des erreurs de jointure, d'ouverture de session, de GPO ou de réplication.

Vérifiez également les enregistrements SRV utilisés par Active Directory :

```cmd
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.local
```

Si cette commande échoue, le domaine peut exister mais le DNS AD n'est pas correctement enregistré.

### 9. Vérifier SYSVOL et NETLOGON

```cmd
net share
```

Vous devez voir au minimum :

```text
SYSVOL
NETLOGON
```

Ces partages sont essentiels pour la distribution des scripts d'ouverture de session et des stratégies de groupe.

### 10. Faire un snapshot

Une fois les vérifications validées, arrêtez proprement `DC01` ou utilisez la fonction de snapshot de votre hyperviseur selon la consigne du formateur.

Nom recommandé :

```text
SNAP_01_DC01_READY
```

## Erreurs fréquentes à éviter

- Promouvoir `DC01` avec une adresse IP en DHCP.
- Laisser un DNS public sur `DC01`.
- Oublier le rôle DNS pendant la promotion.
- Confondre le mot de passe DSRM avec le mot de passe du domaine.
- Continuer les TP suivants alors que `SYSVOL` ou `NETLOGON` sont absents.
- Tester uniquement le ping et oublier la résolution DNS.

## Livrables

Déposez dans votre compte rendu :

- une capture de `ipconfig /all` sur `DC01` ;
- une capture de `Get-ADDomain` ;
- une capture de `Get-ADDomainController` ;
- une capture de `nslookup dc01.lab.local` ;
- une capture de `net share` montrant `SYSVOL` et `NETLOGON` ;
- le nom du snapshot réalisé.

## Questions

1. Pourquoi DNS est-il critique pour Active Directory ?
2. À quoi servent les partages `SYSVOL` et `NETLOGON` ?
3. Quelle différence faites-vous entre le nom DNS `lab.local` et le nom NetBIOS `LAB` ?
4. Pourquoi faut-il faire un snapshot juste après cette étape ?
