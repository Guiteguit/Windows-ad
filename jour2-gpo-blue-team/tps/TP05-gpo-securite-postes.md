# TP05 — GPO de sécurisation des postes

Durée : 1h15

## Objectif

Créer une GPO de sécurisation des postes clients et prouver qu'elle s'applique à `CLIENT01`.

À la fin du TP, vous devez être capable de prouver que :

- la GPO `GPO_SECURITE_POSTES` existe ;
- elle est liée à l'OU des postes ;
- les paramètres Computer Configuration s'appliquent ;
- les paramètres User Configuration s'appliquent via le loopback ;
- `gpresult` ou `rsop.msc` confirme l'application.

## Prérequis

Avant de commencer :

- `CLIENT01` est joint au domaine ;
- `CLIENT01` est dans l'OU :

```text
OU=Workstations,OU=_Postes,DC=lab,DC=local
```

- vous êtes connecté sur `DC01` avec un compte administrateur du domaine ;
- la console Group Policy Management est disponible.

## Rappel : Computer, User et loopback

Une GPO contient deux familles de paramètres :

```text
Computer Configuration : appliqué à l'ordinateur
User Configuration     : appliqué à l'utilisateur
```

Si une GPO est liée à une OU de postes, ses paramètres utilisateur ne s'appliquent pas forcément aux utilisateurs qui ouvrent une session sur ces postes. Pour forcer un comportement utilisateur propre aux machines de l'OU `Workstations`, on active le loopback processing.

Dans ce TP, utilisez le mode :

```text
Merge
```

## Travail demandé

### 1. Vérifier le placement de CLIENT01

Sur `DC01` :

```powershell
Get-ADComputer CLIENT01 -Properties DistinguishedName | Select-Object Name, DistinguishedName
```

`CLIENT01` doit être dans :

```text
OU=Workstations,OU=_Postes,DC=lab,DC=local
```

Si ce n'est pas le cas :

```powershell
Get-ADComputer CLIENT01 | Move-ADObject -TargetPath "OU=Workstations,OU=_Postes,DC=lab,DC=local"
```

### 2. Créer et lier la GPO

Dans `Group Policy Management` :

1. ouvrez la forêt `lab.local` ;
2. ouvrez `Domains > lab.local` ;
3. faites un clic droit sur `OU=Workstations,OU=_Postes` ;
4. choisissez `Create a GPO in this domain, and Link it here...` ;
5. nommez la GPO :

```text
GPO_SECURITE_POSTES
```

Vérifiez que le lien GPO est actif.

### 3. Activer le loopback processing

Dans la GPO :

```text
Computer Configuration
  Policies
    Administrative Templates
      System
        Group Policy
          Configure user Group Policy loopback processing mode
```

Configurez :

```text
Enabled
Mode : Merge
```

### 4. Configurer les paramètres poste

Pare-feu Windows :

```text
Computer Configuration
  Policies
    Windows Defender Firewall
      Domain Profile
```

Activez le pare-feu pour le profil domaine.

Bannière de connexion :

```text
Computer Configuration
  Policies
    Windows Settings
      Security Settings
        Local Policies
          Security Options
```

Configurez :

```text
Interactive logon: Message title for users attempting to log on
Interactive logon: Message text for users attempting to log on
```

Exemple :

```text
Accès réservé aux utilisateurs autorisés du lab.
```

Audit des ouvertures de session :

```text
Computer Configuration
  Policies
    Windows Settings
      Security Settings
        Advanced Audit Policy Configuration
          Audit Policies
            Logon/Logoff
              Audit Logon
```

Activez :

```text
Success and Failure
```

### 5. Configurer les restrictions utilisateur

Interdire le panneau de configuration :

```text
User Configuration
  Policies
    Administrative Templates
      Control Panel
        Prohibit access to Control Panel and PC settings
```

Bloquer `cmd.exe` :

```text
User Configuration
  Policies
    Administrative Templates
      System
        Prevent access to the command prompt
```

Bloquer `regedit.exe` :

```text
User Configuration
  Policies
    Administrative Templates
      System
        Prevent access to registry editing tools
```

Bloquer les supports amovibles :

```text
Computer Configuration
  Policies
    Administrative Templates
      System
        Removable Storage Access
```

Configurez au minimum :

```text
All Removable Storage classes: Deny all access
```

### 6. Forcer et vérifier l'application sur CLIENT01

Sur `CLIENT01`, ouvrez une session avec un utilisateur standard, par exemple :

```text
LAB\user.rh1
```

Exécutez :

```cmd
gpupdate /force
gpresult /r
```

Créez ensuite un rapport HTML :

```cmd
mkdir C:\Temp
gpresult /h C:\Temp\rapport-gpo.html
```

Vous pouvez aussi utiliser :

```cmd
rsop.msc
```

### 7. Tester les effets visibles

Depuis `CLIENT01`, avec `LAB\user.rh1` :

- tentez d'ouvrir le panneau de configuration ;
- tentez d'ouvrir `cmd.exe` ;
- tentez d'ouvrir `regedit.exe` ;
- vérifiez que la GPO apparaît dans `gpresult /r`.

## Résultat attendu

```text
GPO_SECURITE_POSTES visible dans gpresult
Loopback processing activé en Merge
Restrictions utilisateur appliquées sur CLIENT01
Pare-feu domaine actif
Audit logon activé
```

## Dépannage rapide

Si la GPO ne s'applique pas :

- vérifiez que `CLIENT01` est dans la bonne OU ;
- vérifiez que la GPO est liée à cette OU ;
- vérifiez que le lien GPO est activé ;
- vérifiez le filtrage de sécurité ;
- vérifiez que le loopback est activé pour les paramètres utilisateur ;
- vérifiez DNS avec `nltest /dsgetdc:lab.local`.

## Livrables

Déposez dans votre compte rendu :

- une capture du lien `GPO_SECURITE_POSTES` sur l'OU `Workstations` ;
- une capture du paramètre loopback ;
- une capture de `gpresult /r` ;
- le fichier ou une capture du rapport `C:\Temp\rapport-gpo.html` ;
- une capture montrant un effet de restriction sur `CLIENT01`.

## Questions

1. Différence Computer Configuration / User Configuration ?
2. À quoi sert le loopback ?
3. Pourquoi tester sur une OU pilote ?
4. Pourquoi `gpupdate /force` ne suffit-il pas à prouver qu'une GPO est réellement appliquée ?
