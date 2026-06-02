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

### 5. Vérifier les contrôleurs de domaine

Depuis `DC01` ou `DC02` :

```powershell
Get-ADDomainController -Filter * | Select-Object HostName, Site, IPv4Address, IsGlobalCatalog
```

Vous devez voir :

```text
DC01.lab.local
DC02.lab.local
```

### 6. Vérifier DNS et réplication

Sur un contrôleur de domaine :

```cmd
nslookup dc02.lab.local
dcdiag
repadmin /replsummary
repadmin /showrepl
```

Résultat attendu :

```text
pas d'erreur critique dcdiag
0 échec dans repadmin /replsummary
DC01 et DC02 visibles dans la réplication
```

### 7. Tester une modification répliquée

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

## Snapshot recommandé

Nom recommandé :

```text
SNAP_06_DC02_REPLICATION_READY
```

## Livrables

Déposez dans votre compte rendu :

- une capture de `Get-ADDomainController -Filter *` ;
- une capture de `nslookup dc02.lab.local` ;
- une capture de `repadmin /replsummary` ;
- une capture de `repadmin /showrepl` ;
- une capture ou note montrant le test de réplication d'une OU.

## Questions

1. Pourquoi au moins deux DC en production ?
2. Qu'est-ce que la réplication AD ?
3. Pourquoi AD Sites and Services est important ?
4. Pourquoi DNS reste-t-il critique quand plusieurs DC existent ?
