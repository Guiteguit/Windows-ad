# TP00 — Validation du lab

Durée : 45 min

## Objectif

Préparer et valider le socle technique du lab avant l'installation d'Active Directory.

À la fin du TP, vous devez être capable de prouver que :

- les VM sont sur le bon réseau isolé ;
- les noms des machines sont cohérents avec l'architecture ;
- les adresses IP statiques sont configurées ;
- les paramètres DNS sont compatibles avec un futur domaine Active Directory ;
- les machines communiquent entre elles.

## Rappel d'architecture

```text
Réseau LAB : 192.168.56.0/24
Masque     : 255.255.255.0
Passerelle : aucune
Domaine    : lab.local
NetBIOS    : LAB
```

```text
DC01      192.168.56.10   Futur contrôleur de domaine / DNS
DC02      192.168.56.11   Futur contrôleur de domaine secondaire
SRV01     192.168.56.20   Futur serveur de fichiers
CLIENT01  192.168.56.30   Poste client Windows 11
```

## Organisation des installations

Si les VM ne sont pas déjà installées, lancez les installations en parallèle dès le début du créneau.

Attention : l'installation de `CLIENT01` sous Windows 11 peut prendre 2 à 3 heures selon la puissance de l'hôte, le type de disque, les mises à jour et l'hyperviseur. Cette VM doit être lancée immédiatement le matin.

Si `CLIENT01` n'est pas prêt assez tôt, cela peut nuire à la suite du TP : jointure au domaine, tests utilisateur, GPO, accès aux partages SMB et validation du poste client.

Priorité forte :

```text
CLIENT01
```

Windows 11 est souvent plus long à installer et à stabiliser que Windows Server dans ce lab. Il peut demander plus d'étapes de configuration, de redémarrages ou de mises à jour. Ne gardez donc jamais `CLIENT01` pour la fin.

Ordre conseillé :

```text
1. CLIENT01  Windows 11
2. DC01      Windows Server 2019
3. SRV01     Windows Server 2019
4. DC02      Windows Server 2019
```

Pendant les installations, dimensionnez les VM avec :

```text
DC01      2 vCPU   4 Go RAM
DC02      2 vCPU   4 Go RAM
SRV01     2 vCPU   4 Go RAM
CLIENT01  2 vCPU   4 Go RAM minimum, 6 Go RAM si possible
```

Si l'hôte le permet, vous pouvez attribuer temporairement 4 vCPU à `CLIENT01` pendant l'installation de Windows 11. Repassez ensuite à 2 vCPU après installation pour éviter de ralentir l'ensemble du lab.

Après installation, une fois les snapshots de base réalisés, vous pouvez réduire la RAM de certaines VM si l'hôte est limité :

```text
DC01      2 vCPU   4 Go RAM recommandés
CLIENT01  2 vCPU   4 Go RAM minimum, 6 Go RAM si possible
DC02      2 vCPU   2 Go RAM possibles
SRV01     2 vCPU   2 Go RAM possibles
```

Ne réduisez pas la RAM ou le nombre de vCPU pendant une installation ou pendant une mise à jour Windows. Ne mettez pas 4 vCPU sur toutes les VM : cela peut saturer l'hôte et ralentir tout le lab.

## Point important : DNS et Active Directory

Active Directory dépend fortement du DNS. Les postes et serveurs membres ne cherchent pas un domaine AD avec une simple adresse IP : ils utilisent des enregistrements DNS spécifiques, notamment les enregistrements SRV.

Dans ce lab, le serveur DNS de référence sera `DC01`, à l'adresse :

```text
192.168.56.10
```

À retenir :

- `DC01` doit avoir une IP fixe ;
- `SRV01`, `CLIENT01` et plus tard `DC02` doivent utiliser `192.168.56.10` comme DNS ;
- ne configurez pas `8.8.8.8`, `1.1.1.1` ou le DNS de votre box Internet sur les machines du domaine ;
- une mauvaise configuration DNS provoque souvent des erreurs de jointure au domaine, de GPO, d'ouverture de session ou de réplication.

Avant la promotion de `DC01` en contrôleur de domaine, certains tests DNS liés à `lab.local` ne fonctionneront pas encore. C'est normal. Dans ce TP00, on vérifie surtout que la configuration réseau est prête.

## Travail demandé

### 1. Vérifier le réseau virtuel

Dans l'hyperviseur utilisé en cours, vérifiez que les VM sont connectées au même réseau isolé :

- VirtualBox : réseau Host-Only ;
- VMware : VMnet Host-Only ou réseau privé équivalent ;
- Hyper-V : switch interne ou privé ;
- Proxmox : bridge ou réseau de lab dédié.

Le réseau doit être isolé du réseau de production. Ne mélangez pas ce lab avec le réseau de l'entreprise ou de l'école.

### 2. Vérifier le nom des machines

Sur chaque VM, exécutez :

```cmd
hostname
```

Les noms attendus sont :

```text
DC01
DC02
SRV01
CLIENT01
```

Si le nom d'une machine n'est pas correct, renommez-la puis redémarrez.

Exemple PowerShell :

```powershell
Rename-Computer -NewName "SRV01" -Restart
```

Adaptez le nom selon la VM concernée.

### 3. Identifier la carte réseau du lab

Sur chaque VM, affichez les cartes réseau :

```powershell
Get-NetAdapter
```

Repérez le nom de l'interface connectée au réseau Host-Only. Selon votre environnement, elle peut s'appeler `Ethernet`, `Ethernet 2` ou avoir un autre nom.

Dans les commandes suivantes, remplacez `Ethernet` si nécessaire.

### 4. Configurer les adresses IP statiques

Sur `DC01` :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.10 -PrefixLength 24
```

Sur `DC02` :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.11 -PrefixLength 24
```

Sur `SRV01` :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.20 -PrefixLength 24
```

Sur `CLIENT01` :

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.30 -PrefixLength 24
```

Si une adresse IP est déjà configurée sur l'interface, vérifiez-la avant d'en ajouter une nouvelle :

```powershell
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4
```

### 5. Configurer le DNS des endpoints

Sur `SRV01`, `CLIENT01` et `DC02`, configurez `DC01` comme serveur DNS :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10
```

Sur `DC01`, le DNS sera finalisé pendant le TP01 lors de l'installation du rôle AD DS / DNS. Pour préparer la machine, vous pouvez déjà configurer son DNS vers elle-même :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
```

Après la promotion en contrôleur de domaine, `DC01` devra résoudre le domaine `lab.local`.

### 6. Vérifier la configuration IP et DNS

Sur chaque VM :

```cmd
ipconfig /all
```

Contrôlez les points suivants :

- adresse IPv4 conforme au plan d'adressage ;
- masque en `/24` ou `255.255.255.0` ;
- pas de passerelle non demandée ;
- serveur DNS de `SRV01`, `CLIENT01` et `DC02` : `192.168.56.10` ;
- serveur DNS de `DC01` : `127.0.0.1` ou `192.168.56.10` selon l'état de la machine.

### 7. Tester la connectivité IP

Depuis `SRV01` et `CLIENT01` :

```cmd
ping 192.168.56.10
```

Depuis `DC01` :

```cmd
ping 192.168.56.20
ping 192.168.56.30
```

Si le ping échoue, vérifiez :

- que les VM sont sur le même réseau Host-Only ;
- que les adresses IP sont correctes ;
- que le pare-feu Windows ne bloque pas temporairement l'ICMP ;
- que vous testez bien l'adresse de la carte réseau du lab.

### 8. Vérifier le DNS configuré

Sur chaque VM, vérifiez les serveurs DNS configurés :

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

Sur `SRV01`, `CLIENT01` et `DC02`, vous devez retrouver `192.168.56.10`.

À ce stade, la résolution du domaine `lab.local` peut encore échouer si `DC01` n'a pas été promu en contrôleur de domaine. C'est normal : le service DNS Active Directory sera installé et validé dans le TP01.

Après le TP01, les commandes suivantes devront fonctionner :

```cmd
nslookup dc01.lab.local
nslookup lab.local
```

## Configuration attendue

```text
Machine   IP             DNS attendu
DC01      192.168.56.10  127.0.0.1 puis DNS local AD
DC02      192.168.56.11  192.168.56.10
SRV01     192.168.56.20  192.168.56.10
CLIENT01  192.168.56.30  192.168.56.10
```

## Erreurs fréquentes à éviter

- Laisser une machine en DHCP alors que le lab attend une IP fixe.
- Configurer un DNS public sur un serveur ou poste membre du domaine.
- Mettre les VM sur des réseaux virtuels différents.
- Confondre la carte réseau NAT/Internet avec la carte Host-Only du lab.
- Promouvoir `DC01` alors que son IP n'est pas fixe.
- Tenter de joindre `SRV01` ou `CLIENT01` au domaine avant que `DC01` ne fasse DNS pour `lab.local`.

## Livrable

Déposez dans votre compte rendu :

- une capture de `hostname` sur chaque VM ;
- une capture de `ipconfig /all` sur `DC01`, `SRV01` et `CLIENT01` ;
- une capture montrant que `SRV01` ou `CLIENT01` ping `192.168.56.10` ;
- un court paragraphe expliquant le rôle du DNS dans un domaine Active Directory.

## Questions

1. Pourquoi une IP fixe est-elle indispensable pour un contrôleur de domaine ?
2. Pourquoi les postes membres doivent-ils utiliser le DNS du domaine plutôt qu'un DNS public ?
3. Quelle différence faites-vous entre un test `ping` réussi et une résolution DNS réussie ?
