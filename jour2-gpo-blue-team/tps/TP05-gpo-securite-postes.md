# TP05 — GPO de sécurisation des postes

Durée : 1h15

## Objectif

Créer une GPO de sécurisation des postes clients et prouver qu'elle s'applique à `CLIENT01`.

À la fin du TP, vous devez être capable de prouver que :

- la GPO `GPO_SECURITE_POSTES` existe ;
- elle est liée à l'OU des postes ;
- les paramètres Configuration ordinateur (Computer Configuration) s'appliquent ;
- les paramètres Configuration utilisateur (User Configuration) s'appliquent via la boucle de rappel (loopback) ;
- `gpresult` ou `rsop.msc` confirme l'application.

## Prérequis

Avant de commencer :

- `CLIENT01` est joint au domaine ;
- `CLIENT01` est dans l'OU :

```text
OU=Workstations,OU=_Postes,DC=lab,DC=local
```

- vous êtes connecté sur `DC01` avec un compte administrateur du domaine ;
- la console Gestion de stratégie de groupe (Group Policy Management) est disponible.

## Rappel : ordinateur, utilisateur et boucle de rappel

Une GPO contient deux familles de paramètres :

```text
Configuration ordinateur (Computer Configuration) : appliqué à l'ordinateur
Configuration utilisateur (User Configuration)   : appliqué à l'utilisateur
```

Si une GPO est liée à une OU de postes, ses paramètres utilisateur ne s'appliquent pas forcément aux utilisateurs qui ouvrent une session sur ces postes. Pour forcer un comportement utilisateur propre aux machines de l'OU `Workstations`, on active le traitement par boucle de rappel (loopback processing).

Dans ce TP, utilisez le mode :

```text
Fusionner (Merge)
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

Dans `Gestion de stratégie de groupe` (Group Policy Management) :

1. ouvrez la forêt `lab.local` ;
2. ouvrez `Domaines > lab.local` (`Domains > lab.local`) ;
3. faites un clic droit sur `OU=Workstations,OU=_Postes` ;
4. choisissez `Créer un objet GPO dans ce domaine, et le lier ici...` (`Create a GPO in this domain, and Link it here...`) ;
5. nommez la GPO :

```text
GPO_SECURITE_POSTES
```

Vérifiez que le lien GPO est actif.

### 3. Activer la boucle de rappel (loopback processing)

Dans la GPO :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Modèles d'administration (Administrative Templates)
      Système (System)
        Stratégie de groupe (Group Policy)
          Configurer le mode de traitement par bouclage de la stratégie de groupe utilisateur
          (Configure user Group Policy loopback processing mode)
```

Configurez :

```text
Activé (Enabled)
Mode : Fusionner (Merge)
```

### 4. Configurer les paramètres poste

Pare-feu Windows :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Paramètres Windows (Windows Settings)
      Pare-feu Windows Defender (Windows Defender Firewall)
        Profil du domaine (Domain Profile)
```

Activez le pare-feu pour le profil domaine.

Bannière de connexion :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Paramètres Windows (Windows Settings)
      Paramètres de sécurité (Security Settings)
        Stratégies locales (Local Policies)
          Options de sécurité (Security Options)
```

Configurez :

```text
Ouverture de session interactive : titre du message pour les utilisateurs tentant de se connecter
(Interactive logon: Message title for users attempting to log on)

Ouverture de session interactive : contenu du message pour les utilisateurs tentant de se connecter
(Interactive logon: Message text for users attempting to log on)
```

Exemple :

```text
Accès réservé aux utilisateurs autorisés du lab.
```

Audit des ouvertures de session :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Paramètres Windows (Windows Settings)
      Paramètres de sécurité (Security Settings)
        Configuration avancée de la stratégie d'audit (Advanced Audit Policy Configuration)
          Stratégies d'audit (Audit Policies)
            Ouverture/Fermeture de session (Logon/Logoff)
              Auditer l'ouverture de session (Audit Logon)
```

Activez :

```text
Succès et échec (Success and Failure)
```

### 5. Configurer les restrictions utilisateur

Interdire le panneau de configuration :

```text
Configuration utilisateur (User Configuration)
  Stratégies (Policies)
    Modèles d'administration (Administrative Templates)
      Panneau de configuration (Control Panel)
        Interdire l'accès au Panneau de configuration et aux paramètres du PC
        (Prohibit access to Control Panel and PC settings)
```

Bloquer `cmd.exe` :

```text
Configuration utilisateur (User Configuration)
  Stratégies (Policies)
    Modèles d'administration (Administrative Templates)
      Système (System)
        Désactiver l'accès à l'invite de commandes
        (Prevent access to the command prompt)
```

Bloquer `regedit.exe` :

```text
Configuration utilisateur (User Configuration)
  Stratégies (Policies)
    Modèles d'administration (Administrative Templates)
      Système (System)
        Empêcher l'accès aux outils de modification du Registre
        (Prevent access to registry editing tools)
```

Bloquer les supports amovibles :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Modèles d'administration (Administrative Templates)
      Système (System)
        Accès au stockage amovible (Removable Storage Access)
```

Configurez au minimum :

```text
Toutes les classes de stockage amovible : refuser tous les accès
(All Removable Storage classes: Deny all access)
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
Traitement par boucle de rappel (loopback processing) activé en Fusionner (Merge)
Restrictions utilisateur appliquées sur CLIENT01
Pare-feu domaine actif
Audit des ouvertures de session (Audit Logon) activé
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
- une capture du paramètre boucle de rappel (loopback) ;
- une capture de `gpresult /r` ;
- le fichier ou une capture du rapport `C:\Temp\rapport-gpo.html` ;
- une capture montrant un effet de restriction sur `CLIENT01`.

## Questions

1. Différence Configuration ordinateur (Computer Configuration) / Configuration utilisateur (User Configuration) ?
2. À quoi sert la boucle de rappel (loopback) ?
3. Pourquoi tester sur une OU pilote ?
4. Pourquoi `gpupdate /force` ne suffit-il pas à prouver qu'une GPO est réellement appliquée ?
