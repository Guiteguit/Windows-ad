# TP08 — DC02, réplication et disponibilité

Durée : 1h15

## Objectif

Ajouter un second contrôleur de domaine et vérifier la réplication Active Directory.

À la fin du TP, vous devez être capable de prouver que :

- `DC02` est joint au domaine ;
- le rôle AD DS est installé ;
- `DC02` est contrôleur de domaine et serveur DNS ;
- la réplication entre `DC01` et `DC02` fonctionne ;
- les deux DC sont visibles dans Active Directory.

## Point de compréhension : rôle réel de DC02

Dans ce TP, `DC02` n'est pas un simple serveur de sauvegarde passif.

Après promotion, `DC02` devient un contrôleur de domaine additionnel, accessible en lecture et en écriture. Il peut authentifier des utilisateurs, répondre aux requêtes LDAP/Kerberos, appliquer des GPO et recevoir des modifications Active Directory.

Active Directory fonctionne en réplication multi-maître :

```text
modification sur DC01 -> réplication vers DC02
modification sur DC02 -> réplication vers DC01
```

`DC02` n'est pas en lecture seule, sauf si vous choisissez explicitement de déployer un RODC (Read-Only Domain Controller). Un RODC est utile pour un site distant peu sécurisé, mais ce n'est pas le cas de ce lab.

### Et si DC01 tombe ?

Si `DC01` tombe mais que `DC02` est correctement promu et que DNS est bien configuré :

- les utilisateurs peuvent continuer à s'authentifier auprès de `DC02` ;
- les postes peuvent continuer à localiser un contrôleur de domaine ;
- les GPO déjà répliquées peuvent continuer à s'appliquer ;
- le DNS AD peut continuer à répondre depuis `DC02`.

Mais `DC02` ne reprend pas automatiquement tous les rôles au sens complet du terme. Les rôles FSMO restent sur leur détenteur initial tant qu'ils ne sont pas transférés ou saisis.

Dans ce lab, les rôles FSMO restent probablement sur `DC01`. Si `DC01` est indisponible durablement, certaines opérations peuvent être impactées, par exemple :

- opérations liées au PDC Emulator ;
- création massive d'objets nécessitant des pools RID ;
- modification du schéma ;
- changements liés aux domaines de la forêt.

Conclusion : `DC02` apporte de la disponibilité pour l'authentification, DNS, LDAP et GPO, mais il ne remplace pas une stratégie complète de sauvegarde, supervision, restauration et gestion des rôles FSMO.

### Et pour DNS ?

Quand `DC02` est promu avec `-InstallDNS`, il héberge aussi le rôle DNS. Dans un domaine AD, les zones DNS intégrées à Active Directory sont répliquées entre contrôleurs de domaine DNS.

On ne raisonne donc pas comme avec une zone DNS primaire/secondaire classique. On configure plutôt les clients avec deux serveurs DNS :

```text
DNS préféré    : DC01  192.168.56.10
DNS auxiliaire : DC02  192.168.56.11
```

Ainsi, si `DC01` ne répond plus, les machines peuvent interroger `DC02`.

## Prérequis

Avant de commencer :

- `DC01` fonctionne correctement ;
- `DC02` a l'adresse IP `192.168.56.11` ;
- `DC02` utilise `192.168.56.10` comme DNS ;
- aucun ancien rôle AD DS partiellement installé ne bloque la machine ;
- vous disposez d'un compte administrateur du domaine.

## Travail demandé

### 1. Vérifier DC02 avant jointure

Sur `DC02` :

```cmd
hostname
ipconfig /all
ping 192.168.56.10
nslookup dc01.lab.local
nltest /dsgetdc:lab.local
```

Le DNS de `DC02` doit pointer vers :

```text
192.168.56.10
```

### 2. Joindre DC02 au domaine

Sur `DC02` :

```powershell
Add-Computer -DomainName lab.local -Restart
```

Après redémarrage, connectez-vous avec un compte du domaine.

### 3. Installer AD DS

Sur `DC02`, ouvrez PowerShell en administrateur :

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

Vérifiez :

```powershell
Get-WindowsFeature AD-Domain-Services
```

### 4. Promouvoir DC02 comme contrôleur de domaine additionnel

Sur `DC02` :

```powershell
Install-ADDSDomainController -DomainName "lab.local" -InstallDNS
```

Renseignez le mot de passe DSRM lorsque l'assistant le demande. La machine redémarre après promotion.

### 5. Configurer DNS après promotion de DC02

Après la promotion, `DC02` devient aussi serveur DNS. Il faut donc ajouter `192.168.56.11` comme DNS auxiliaire sur les machines membres du domaine.

Sur `SRV01` et `CLIENT01` :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10,192.168.56.11
```

Sur `DC02`, gardez `DC01` en DNS préféré et ajoutez le DNS local en secours :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10,127.0.0.1
```

Sur `DC01`, vous pouvez ajouter `DC02` comme DNS préféré ou auxiliaire. Pour ce lab :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.11,127.0.0.1
```

Vérifiez sur chaque machine :

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

Remplacez `Ethernet` par le nom réel de l'interface si nécessaire.

### 6. Vérifier les contrôleurs de domaine

Depuis `DC01` ou `DC02` :

```powershell
Get-ADDomainController -Filter * | Select-Object HostName, Site, IPv4Address, IsGlobalCatalog, OperationMasterRoles
```

Vous devez voir :

```text
DC01.lab.local
DC02.lab.local
```

Vérifiez aussi où se trouvent les rôles FSMO :

```cmd
netdom query fsmo
```

### 7. Vérifier DNS et réplication

Sur un contrôleur de domaine :

```cmd
nslookup dc02.lab.local
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.local
dcdiag
repadmin /replsummary
repadmin /showrepl
```

Résultat attendu :

```text
pas d'erreur critique dcdiag
0 échec dans repadmin /replsummary
DC01 et DC02 visibles dans la réplication
les enregistrements DNS SRV retournent DC01 et/ou DC02
```

### 8. Tester une modification répliquée

Sur `DC01`, créez une OU de test :

```powershell
New-ADOrganizationalUnit -Name "Replication-Test" -Path "DC=lab,DC=local"
```

Sur `DC02`, vérifiez qu'elle existe :

```powershell
Get-ADOrganizationalUnit -Filter "Name -eq 'Replication-Test'"
```

Supprimez ensuite l'OU de test si elle n'est plus utile :

```powershell
$TestOu = Get-ADOrganizationalUnit -Filter "Name -eq 'Replication-Test'"
$TestOu | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false
$TestOu | Remove-ADOrganizationalUnit -Confirm:$false
```

### 9. Tester le comportement si DC01 est indisponible

Simulation courte, uniquement si le formateur l'autorise :

1. arrêtez temporairement `DC01` ;
2. sur `CLIENT01`, vérifiez que le DNS auxiliaire est bien configuré ;
3. testez la localisation du domaine :

```cmd
nltest /dsgetdc:lab.local
nslookup dc02.lab.local
gpupdate /force
```

Résultat attendu :

```text
CLIENT01 doit pouvoir trouver DC02 comme contrôleur de domaine
DNS doit répondre via 192.168.56.11
```

Redémarrez ensuite `DC01` et vérifiez de nouveau la réplication :

```cmd
repadmin /replsummary
```

## Dépannage rapide

Si la promotion échoue :

- vérifiez DNS sur `DC02` ;
- vérifiez `nltest /dsgetdc:lab.local` ;
- vérifiez l'heure système entre `DC01` et `DC02` ;
- vérifiez que le compte utilisé est administrateur du domaine.

Si la réplication échoue :

- vérifiez `repadmin /showrepl` ;
- vérifiez la résolution de `dc01.lab.local` et `dc02.lab.local` ;
- vérifiez que les deux DC communiquent sur le réseau du lab ;
- vérifiez l'Observateur d'événements Directory Service.

Si les clients ne basculent pas vers `DC02` quand `DC01` est arrêté :

- vérifiez que `192.168.56.11` est bien configuré comme DNS auxiliaire ;
- vérifiez que `DC02` répond aux requêtes DNS ;
- vérifiez les enregistrements SRV ;
- vérifiez que `DC02` est bien contrôleur de domaine et catalogue global.

## Snapshot recommandé

Nom recommandé :

```text
SNAP_06_DC02_REPLICATION_READY
```

## Livrables

Déposez dans votre compte rendu :

- une capture de `Get-ADDomainController -Filter *` ;
- une capture de `nslookup dc02.lab.local` ;
- une capture de la configuration DNS avec `192.168.56.10` et `192.168.56.11` ;
- une capture de `repadmin /replsummary` ;
- une capture de `repadmin /showrepl` ;
- une capture ou note montrant le test de réplication d'une OU.

## Questions

1. Pourquoi au moins deux DC en production ?
2. Qu'est-ce que la réplication AD ?
3. Pourquoi AD Sites and Services est important ?
4. Pourquoi DNS reste-t-il critique quand plusieurs DC existent ?
5. `DC02` est-il un contrôleur de domaine en lecture seule dans ce lab ? Pourquoi ?
6. Que sont les rôles FSMO et pourquoi ne faut-il pas les confondre avec la disponibilité DNS/authentification ?
