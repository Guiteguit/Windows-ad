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

Dans Active Directory, la politique de mot de passe par défaut du domaine se configure au niveau du domaine, généralement via `Default Domain Policy` ou une GPO équivalente liée au domaine.

Une GPO de mot de passe liée à une OU utilisateur classique ne modifie pas la politique de mot de passe du domaine pour tous les comptes.

## Travail demandé

### 1. Ouvrir la politique du domaine

Sur `DC01`, ouvrez `Group Policy Management`.

Éditez :

```text
Default Domain Policy
```

ou une GPO dédiée liée directement à :

```text
lab.local
```

### 2. Configurer la politique de mot de passe

Chemin :

```text
Computer Configuration
  Policies
    Windows Settings
      Security Settings
        Account Policies
          Password Policy
```

Configurez :

```text
Minimum password length         : 12
Password must meet complexity   : Enabled
Enforce password history        : 10
```

### 3. Configurer le verrouillage

Chemin :

```text
Computer Configuration
  Policies
    Windows Settings
      Security Settings
        Account Policies
          Account Lockout Policy
```

Configurez :

```text
Account lockout threshold       : 3 invalid logon attempts
Account lockout duration        : 15 minutes
Reset account lockout counter   : 15 minutes
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

- une capture des paramètres Password Policy ;
- une capture des paramètres Account Lockout Policy ;
- une capture de `net accounts` ;
- une capture de `Search-ADAccount -LockedOut` montrant `user.rh1` verrouillé ;
- une capture ou note montrant le déverrouillage.

## Questions

1. Pourquoi une politique trop stricte peut-elle créer un DoS ?
2. Pourquoi complexité seule ne suffit pas ?
3. Pourquoi la politique de mot de passe doit-elle être liée au domaine ?
