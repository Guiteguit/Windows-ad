# TP10 — Intégration AD avec IIS et SSO Kerberos

Durée : 45 min à 1h

## Objectif

Intégrer un service applicatif simple à Active Directory et démontrer une authentification unique (SSO) sur un intranet.

Dans ce TP, `SRV01` héberge un petit site IIS interne. Depuis `CLIENT01`, un utilisateur du domaine accède au site avec sa session Windows, sans ressaisir son mot de passe.

À la fin du TP, vous devez être capable de prouver que :

- IIS est installé sur `SRV01` ;
- le site utilise l'authentification Windows ;
- l'accès anonyme est désactivé ;
- un utilisateur du domaine accède au site depuis `CLIENT01` ;
- un ticket Kerberos est obtenu pour le service HTTP ;
- le rôle du DNS et du SPN est compris.

## Prérequis

Avant de commencer :

- `DC01` est contrôleur de domaine et DNS ;
- `SRV01` est joint au domaine `lab.local` ;
- `CLIENT01` est joint au domaine `lab.local` ;
- `SRV01` et `CLIENT01` utilisent le DNS AD ;
- vous disposez d'un compte administrateur du domaine ;
- vous pouvez ouvrir une session sur `CLIENT01` avec un utilisateur standard, par exemple `LAB\user.rh1`.

## Point de compréhension : SSO, Kerberos et SPN

Dans un domaine Active Directory, l'authentification unique repose souvent sur Kerberos.

Principe simplifié :

```text
1. L'utilisateur ouvre une session sur CLIENT01.
2. CLIENT01 obtient un ticket Kerberos auprès du contrôleur de domaine.
3. L'utilisateur accède à http://srv01.lab.local.
4. CLIENT01 demande un ticket de service pour HTTP/srv01.lab.local.
5. IIS valide le ticket et autorise l'accès sans redemander le mot de passe.
```

Pour que Kerberos fonctionne correctement, le nom du service doit être connu dans Active Directory. C'est le rôle du SPN, pour Service Principal Name.

Exemple :

```text
HTTP/srv01.lab.local
```

Ce SPN indique qu'un service HTTP est disponible sur `srv01.lab.local` et qu'il est porté par un compte AD. Dans ce lab, le service IIS utilise le compte ordinateur de `SRV01`.

À retenir :

- DNS permet de résoudre `srv01.lab.local` vers l'adresse IP de `SRV01` ;
- le SPN permet à Kerberos d'associer le service HTTP au bon compte AD ;
- l'authentification Windows dans IIS permet d'utiliser la session domaine ;
- si le SPN est absent ou en doublon, Kerberos peut échouer ou basculer vers NTLM.

## Travail demandé

### 1. Vérifier la résolution DNS

Depuis `CLIENT01` :

```cmd
nslookup srv01.lab.local
ping srv01.lab.local
nltest /dsgetdc:lab.local
```

Résultat attendu :

```text
srv01.lab.local doit résoudre vers 192.168.56.20
CLIENT01 doit trouver un contrôleur de domaine
```

### 2. Installer IIS et l'authentification Windows

Sur `SRV01`, ouvrez PowerShell en administrateur :

```powershell
Install-WindowsFeature Web-Server,Web-Windows-Auth,Web-ASP -IncludeManagementTools
```

Vérifiez :

```powershell
Get-WindowsFeature Web-Server,Web-Windows-Auth,Web-ASP
```

### 3. Créer une page de test

Sur `SRV01`, créez une page ASP qui affiche l'utilisateur authentifié :

```powershell
@'
<html>
<head><title>LAB SSO IIS</title></head>
<body>
<h1>LAB SSO IIS</h1>
<p>Utilisateur authentifie :</p>
<pre><%= Request.ServerVariables("LOGON_USER") %></pre>
<p>Serveur :</p>
<pre><%= Request.ServerVariables("SERVER_NAME") %></pre>
</body>
</html>
'@ | Set-Content -Path "C:\inetpub\wwwroot\index.asp" -Encoding ASCII
```

### 4. Activer l'authentification Windows et désactiver l'anonyme

Sur `SRV01` :

```powershell
Import-Module WebAdministration

Set-WebConfigurationProperty `
  -Filter "/system.webServer/security/authentication/anonymousAuthentication" `
  -Name enabled `
  -Value false `
  -PSPath "IIS:\"

Set-WebConfigurationProperty `
  -Filter "/system.webServer/security/authentication/windowsAuthentication" `
  -Name enabled `
  -Value true `
  -PSPath "IIS:\"
```

Vérifiez :

```powershell
Get-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name enabled -PSPath "IIS:\"
Get-WebConfigurationProperty -Filter "/system.webServer/security/authentication/windowsAuthentication" -Name enabled -PSPath "IIS:\"
```

Résultat attendu :

```text
anonymousAuthentication : False
windowsAuthentication   : True
```

### 5. Vérifier ou créer le SPN HTTP

Sur `DC01`, vérifiez les SPN du compte ordinateur `SRV01` :

```cmd
setspn -L LAB\SRV01$
```

Ajoutez les SPN HTTP si nécessaire :

```cmd
setspn -S HTTP/srv01 LAB\SRV01$
setspn -S HTTP/srv01.lab.local LAB\SRV01$
```

Important :

- utilisez `-S` et pas `-A`, car `-S` vérifie les doublons ;
- si la commande indique que le SPN existe déjà, ne forcez pas ;
- un SPN dupliqué peut casser Kerberos.

Vérifiez de nouveau :

```cmd
setspn -L LAB\SRV01$
```

### 6. Déclarer le domaine lab.local comme intranet local

Sur `CLIENT01`, ouvrez une session avec :

```text
LAB\user.rh1
```

Pour que le navigateur envoie automatiquement les identifiants Windows, le site doit être considéré comme faisant partie de l'intranet local.

Méthode graphique :

```text
Options Internet
  Sécurité
    Intranet local
      Sites
        Avancé
```

Ajoutez :

```text
http://*.lab.local
```

Méthode PowerShell, à exécuter dans la session de l'utilisateur qui teste :

```powershell
New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\lab.local\*" -Force
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\lab.local\*" -Name "http" -Value 1 -PropertyType DWord -Force
```

Fermez puis rouvrez le navigateur après cette modification.

### 7. Tester le SSO depuis CLIENT01

Sur `CLIENT01`, avec la session `LAB\user.rh1`, ouvrez le navigateur et accédez à :

```text
http://srv01.lab.local/index.asp
```

Résultat attendu :

```text
la page s'ouvre sans ressaisie du mot de passe
la page affiche LAB\user.rh1 ou lab\user.rh1
```

Si le navigateur demande un mot de passe, consultez la partie dépannage.

### 8. Vérifier le ticket Kerberos

Sur `CLIENT01`, ouvrez une invite de commandes :

```cmd
klist
```

Cherchez un ticket de service contenant :

```text
HTTP/srv01.lab.local
```

Vous pouvez purger les tickets puis retester :

```cmd
klist purge
```

Retournez ensuite sur :

```text
http://srv01.lab.local/index.asp
```

Puis relancez :

```cmd
klist
```

### 9. Observer les logs IIS

Sur `SRV01`, ouvrez le dossier des logs IIS :

```powershell
Get-ChildItem "C:\inetpub\logs\LogFiles" -Recurse
```

Vous pouvez ouvrir le dernier fichier `.log` et repérer les accès depuis `CLIENT01`.

## Résultat attendu

```text
IIS installé sur SRV01
authentification Windows activée
accès anonyme désactivé
SPN HTTP présent sur LAB\SRV01$
lab.local déclaré comme intranet local sur CLIENT01
CLIENT01 accède au site en SSO
klist montre un ticket HTTP/srv01.lab.local
```

## Dépannage rapide

### Le navigateur demande un mot de passe

Vérifiez :

```cmd
nslookup srv01.lab.local
klist
```

Puis :

- utilisez l'URL `http://srv01.lab.local/index.asp`, pas seulement l'adresse IP ;
- vérifiez que `http://*.lab.local` est dans la zone Intranet local ;
- fermez puis rouvrez le navigateur après modification de la zone ;
- vérifiez que `CLIENT01` est bien joint au domaine ;
- vérifiez que l'utilisateur est connecté avec un compte du domaine ;
- vérifiez que l'authentification Windows est activée dans IIS ;
- vérifiez que l'accès anonyme est désactivé.

### Kerberos ne semble pas utilisé

Vérifiez les SPN :

```cmd
setspn -L LAB\SRV01$
setspn -Q HTTP/srv01.lab.local
```

Si le SPN est absent, ajoutez-le. S'il est dupliqué, ne corrigez pas au hasard : documentez et demandez validation au formateur.

### L'accès fonctionne avec l'IP mais pas avec le nom

Vérifiez DNS :

```cmd
nslookup srv01.lab.local
ipconfig /all
```

Kerberos dépend du nom de service. Tester avec une IP peut provoquer un comportement différent et ne prouve pas le SSO Kerberos.

### Erreur 401 dans le navigateur

Vérifiez :

- l'authentification Windows dans IIS ;
- les droits NTFS sur `C:\inetpub\wwwroot` ;
- le compte utilisé côté client ;
- les journaux IIS ;
- les journaux Security sur `SRV01`.

## Livrables

Déposez dans votre compte rendu :

- une capture de `Get-WindowsFeature Web-Server,Web-Windows-Auth,Web-ASP` ;
- une capture des paramètres IIS montrant Windows Authentication activé et Anonymous Authentication désactivé ;
- une capture de `setspn -L LAB\SRV01$` ;
- une capture de la page `http://srv01.lab.local/index.asp` affichant l'utilisateur ;
- une capture de `klist` montrant un ticket `HTTP/srv01.lab.local` ;
- une courte explication du lien entre DNS, SPN, Kerberos et SSO.

## Questions

1. Pourquoi faut-il accéder au site par son nom DNS plutôt que par son adresse IP ?
2. À quoi sert un SPN dans Kerberos ?
3. Pourquoi un SPN dupliqué est-il dangereux ?
4. Quelle différence faites-vous entre authentification Windows, Kerberos et SSO ?
5. Pourquoi cette intégration illustre-t-elle le lien entre Active Directory et un service applicatif ?
