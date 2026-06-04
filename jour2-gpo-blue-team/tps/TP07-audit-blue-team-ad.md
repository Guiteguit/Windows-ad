# TP07 — Audit AD et investigation Blue Team

Durée : 1h30

## Objectif

Activer l'audit des événements Active Directory sensibles, générer une activité suspecte contrôlée, puis produire une chronologie d'investigation.

À la fin du TP, vous devez être capable de prouver que :

- l'audit est actif ;
- les créations et modifications de comptes sont visibles ;
- les ajouts dans un groupe sensible sont retrouvés ;
- une chronologie simple permet d'expliquer l'incident ;
- les actions correctives sont documentées.

## Prérequis

Avant de commencer :

- `DC01` est opérationnel ;
- `CLIENT01` est joint au domaine ;
- les comptes et groupes du TP03 existent ;
- vous êtes connecté sur `DC01` avec un compte administrateur du domaine ;
- la GPO `GPO_SECURITE_POSTES` ou une autre GPO n'empêche pas vos tests.

## Rappel : événements utiles

```text
4720  Création utilisateur
4728  Ajout dans un groupe global
4729  Retrait d'un groupe global
4738  Modification utilisateur
4625  Échec d'ouverture de session
4624  Ouverture de session réussie
```

Selon le groupe modifié, Windows peut produire d'autres IDs proches, par exemple `4732` pour certains groupes locaux. L'important est de retrouver l'action, le compte cible, le groupe et le compte source.

## Travail demandé

### 1. Créer la GPO d'audit

Dans `Gestion de stratégie de groupe` (Group Policy Management), créez une GPO nommée :

```text
GPO_AUDIT_AD
```

Liez-la au domaine :

```text
lab.local
```

### 2. Activer les politiques d'audit avancées

Dans la GPO :

```text
Configuration ordinateur (Computer Configuration)
  Stratégies (Policies)
    Paramètres Windows (Windows Settings)
      Paramètres de sécurité (Security Settings)
        Configuration avancée de la stratégie d'audit (Advanced Audit Policy Configuration)
          Stratégies d'audit (Audit Policies)
```

Activez en `Succès et échec` (`Success and Failure`) :

```text
Ouverture de session de compte (Account Logon)
Gestion des comptes (Account Management)
Ouverture/Fermeture de session (Logon/Logoff)
Changement de stratégie (Policy Change)
```

### 3. Appliquer et vérifier l'audit

Sur `DC01` :

```cmd
gpupdate /force
auditpol /get /category:*
```

Vous devez retrouver les catégories activées.

### 4. Générer une activité suspecte contrôlée

Sur `DC01`, créez un compte suspect :

```powershell
$Password = ConvertTo-SecureString "P@ssw0rd-Suspect-2026!" -AsPlainText -Force
New-ADUser -Name "backup-admin" -SamAccountName "backup-admin" -UserPrincipalName "backup-admin@lab.local" -Path "OU=_Admins,DC=lab,DC=local" -AccountPassword $Password -Enabled $true
```

Ajoutez-le dans un groupe sensible :

```powershell
Add-ADGroupMember -Identity "Admins du domaine" -Members "backup-admin"
```

Générez aussi un échec de connexion depuis `CLIENT01` avec un mauvais mot de passe pour :

```text
LAB\backup-admin
```

### 5. Retrouver les événements

Sur `DC01`, utilisez l'Observateur d'événements :

```text
Windows Logs
  Security
```

Filtrez sur les Event IDs :

```text
4720, 4728, 4729, 4738, 4625, 4624
```

Vous pouvez aussi utiliser PowerShell :

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4720,4728,4738,4625} -MaxEvents 20 |
  Select-Object TimeCreated, Id, ProviderName, Message
```

Pour un rapport plus lisible, notez au minimum :

```text
heure
Event ID
compte source
compte cible
groupe modifié
machine concernée
risque
```

### 6. Corriger l'incident

Retirez le compte du groupe sensible :

```powershell
Remove-ADGroupMember -Identity "Admins du domaine" -Members "backup-admin" -Confirm:$false
```

Désactivez le compte :

```powershell
Disable-ADAccount -Identity "backup-admin"
```

Vérifiez :

```powershell
Get-ADUser backup-admin -Properties Enabled | Select-Object SamAccountName, Enabled
Get-ADGroupMember "Admins du domaine"
```

## Résultat attendu

Le rapport doit expliquer :

```text
un compte backup-admin a été créé
il a été ajouté dans un groupe sensible
un échec de connexion a été observé
le compte a été retiré du groupe puis désactivé
```

## Dépannage rapide

Si les événements ne remontent pas :

- vérifiez `auditpol /get /category:*` ;
- vérifiez que vous consultez le journal Security du bon contrôleur de domaine ;
- relancez `gpupdate /force` sur `DC01` ;
- générez de nouveau l'action suspecte ;
- notez que certains événements peuvent être enregistrés sur le DC qui traite réellement l'authentification.

## Livrable

Rédigez un rapport d'investigation avec :

- chronologie ;
- comptes concernés ;
- groupes modifiés ;
- Event IDs ;
- risque ;
- actions correctives ;
- mesure préventive.

Utilisez le modèle :

```text
livrables/template-rapport-incident.md
```

## Questions

1. Pourquoi un ajout dans `Admins du domaine` est-il critique ?
2. Pourquoi l'audit doit-il être activé avant l'incident ?
3. Quelle différence faites-vous entre preuve technique et hypothèse ?
4. Quelle mesure préventive limiterait le risque de compte administrateur non maîtrisé ?
