# TP06 — Politique de mot de passe et verrouillage

Durée : 45 min

## Objectif

Configurer une politique de mot de passe et de verrouillage cohérente pour le domaine `lab.local`.

À la fin du TP, vous devez être capable de prouver que :

- la politique de mot de passe du domaine est configurée ;
- le verrouillage de compte fonctionne ;
- un compte verrouillé est détectable ;
- un compte peut être déverrouillé proprement.

## Paramètres attendus

- mot de passe minimum 12 caractères ;
- complexité activée ;
- historique 10 ;
- verrouillage après 3 échecs ;
- durée de verrouillage 15 min.

## Point important

Dans Active Directory, la politique de mot de passe par défaut du domaine se configure au niveau du domaine, généralement via `Stratégie de domaine par défaut` (`Default Domain Policy`) ou une GPO équivalente liée au domaine.

Une GPO de mot de passe liée à une OU utilisateur classique ne modifie pas la politique de mot de passe du domaine pour tous les comptes.

## Travail demandé

### 1. Ouvrir la politique du domaine

Sur `DC01`, ouvrez `Gestion de stratégie de groupe` (Group Policy Management).

Éditez :

```text
Stratégie de domaine par défaut (Default Domain Policy)
```

ou une GPO dédiée liée directement à :

```text
lab.local
```

### 2. Configurer la politique de mot de passe

Chemin :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Paramètres Windows (Windows Settings)
      Paramètres de sécurité (Security Settings)
        Stratégies de comptes (Account Policies)
          Stratégie de mot de passe (Password Policy)
```

Configurez :

```text
Longueur minimale du mot de passe (Minimum password length)        : 12
Le mot de passe doit respecter des exigences de complexité
(Password must meet complexity requirements)                       : Activé (Enabled)
Conserver l'historique des mots de passe (Enforce password history): 10
```

### 3. Configurer le verrouillage

Chemin :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Paramètres Windows (Windows Settings)
      Paramètres de sécurité (Security Settings)
        Stratégies de comptes (Account Policies)
          Stratégie de verrouillage du compte (Account Lockout Policy)
```

Configurez :

```text
Seuil de verrouillage du compte (Account lockout threshold)                : 3 tentatives non valides
Durée de verrouillage du compte (Account lockout duration)                 : 15 minutes
Réinitialiser le compteur de verrouillages du compte après
(Reset account lockout counter after)                                      : 15 minutes
```

### 4. Appliquer et vérifier

Sur `DC01` :

```cmd
gpupdate /force
net accounts
```

Vous devez retrouver les valeurs configurées.

Vous pouvez aussi vérifier en PowerShell :

```powershell
Get-ADDefaultDomainPasswordPolicy
```

### 5. Tester le verrouillage

Depuis `CLIENT01`, tentez 3 mauvaises authentifications avec :

```text
LAB\user.rh1
```

Sur `DC01`, vérifiez :

```powershell
Search-ADAccount -LockedOut
```

Déverrouillez ensuite le compte :

```powershell
Unlock-ADAccount -Identity "user.rh1"
```

Vérifiez qu'il n'est plus verrouillé :

```powershell
Search-ADAccount -LockedOut
```

## Dépannage rapide

Si le compte ne se verrouille pas :

- vérifiez que la GPO est liée au domaine ;
- vérifiez `net accounts` sur un contrôleur de domaine ;
- vérifiez que vous testez bien un compte du domaine ;
- attendez ou forcez l'actualisation de stratégie ;
- ne testez pas avec un compte administrateur critique.

## Livrables

Déposez dans votre compte rendu :

- une capture des paramètres Stratégie de mot de passe (Password Policy) ;
- une capture des paramètres Stratégie de verrouillage du compte (Account Lockout Policy) ;
- une capture de `net accounts` ;
- une capture de `Search-ADAccount -LockedOut` montrant `user.rh1` verrouillé ;
- une capture ou note montrant le déverrouillage.

## Questions

1. Pourquoi une politique trop stricte peut-elle créer un DoS ?
2. Pourquoi complexité seule ne suffit pas ?
3. Pourquoi la politique de mot de passe doit-elle être liée au domaine ?
