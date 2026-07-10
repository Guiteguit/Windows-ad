# TP noté 3h — Audit, sécurisation et investigation Active Directory

## Matière

**Windows Active Directory — M1 Cybersécurité**

## Durée

**3 heures**

## Note

**/20**

## Contexte

Vous êtes administrateur cybersécurité pour le domaine Active Directory :

```text
lab.local
```

L’infrastructure est déjà déployée et doit être conservée en l’état.

Architecture attendue :

| Machine | Rôle |
|---|---|
| `DC01` | Contrôleur de domaine principal / DNS |
| `DC02` | Contrôleur de domaine secondaire |
| `SRV01` | Serveur de fichiers |
| `CLIENT01` | Poste client joint au domaine |

Vous devez réaliser un audit technique, appliquer une sécurisation contrôlée, générer des événements de sécurité, puis produire un rapport professionnel.

Ce TP est conçu pour être réalisé à distance. Le formateur n’a pas accès à vos machines. Vous devez donc fournir des preuves claires : captures, commandes, résultats, exports et explications.

---

# Objectifs

À la fin du TP, vous devez être capable de :

- auditer rapidement la santé d’un domaine Active Directory ;
- vérifier la configuration DNS et la localisation d’un contrôleur de domaine ;
- créer une structure AD propre avec utilisateurs, groupes et modèle AGDLP ;
- configurer un partage SMB avec permissions SMB et NTFS ;
- créer et vérifier une GPO de sécurisation ;
- générer et analyser des événements de sécurité Windows ;
- différencier les événements locaux et les événements côté contrôleur de domaine ;
- produire un compte rendu clair, structuré et exploitable.

---

# Règles importantes

Vous ne devez pas casser l’infrastructure existante.

Toutes les ressources créées pour le TP doivent être préfixées par :

```text
EVAL_
```

Exemples :

```text
EVAL_DUPONT_USER
EVAL_DUPONT_GG_AUDIT
EVAL_DUPONT_DL_SHARE_RW
GPO_EVAL_DUPONT_SECURITY
```

Dans toutes les commandes, remplacez :

```text
<votre_nom>
```

par votre nom ou votre identifiant étudiant, sans espace ni caractère spécial.

Exemple :

```text
EVAL_DUPONT
eval.dupont
```

---

# Rendu attendu

Vous devez rendre un fichier compressé :

```text
NOM_Prenom_TP_AD_3H.zip
```

Il doit contenir :

```text
1. Rapport au format PDF ou Markdown
2. Transcript PowerShell
3. Rapport gpresult HTML
4. Captures d’écran principales
```

Le rapport doit contenir :

```text
1. Page de garde
2. Architecture du lab
3. Audit initial AD
4. Création utilisateurs / groupes / AGDLP
5. Partage SMB et permissions
6. GPO de sécurisation
7. Audit Event Viewer
8. Synthèse sécurité
9. Commandes utilisées
10. Captures ou preuves
11. Difficultés rencontrées
12. Conclusion
```

---

# Démarrage obligatoire du TP

Sur `DC01`, ouvrez PowerShell en administrateur et lancez une trace :

```powershell
New-Item -Path "C:\Temp" -ItemType Directory -Force

Start-Transcript -Path "C:\Temp\EVAL_AD_<votre_nom>.txt"

hostname
whoami
Get-Date
```

À la fin du TP, vous devrez arrêter la trace avec :

```powershell
Stop-Transcript
```

Le fichier suivant devra être joint au rendu :

```text
C:\Temp\EVAL_AD_<votre_nom>.txt
```

---

# Planning conseillé

| Étape | Durée conseillée |
|---|---:|
| Lecture du sujet | 10 min |
| Partie 1 — Audit initial AD | 25 min |
| Partie 2 — Utilisateurs / groupes / AGDLP | 35 min |
| Partie 3 — Partage SMB / NTFS | 35 min |
| Partie 4 — GPO de sécurisation | 35 min |
| Partie 5 — Audit Event Viewer | 45 min |
| Partie 6 — Synthèse sécurité | 20 min |
| Rédaction finale | 20 min |

---

# Partie 1 — Audit initial du domaine

## Objectif

Vérifier la santé minimale du domaine Active Directory et de la configuration réseau.

## Travail demandé depuis CLIENT01

Exécutez les commandes suivantes :

```cmd
ipconfig /all
nslookup dc01.lab.local
nltest /dsgetdc:lab.local
echo %logonserver%
whoami /groups
```

## Travail demandé depuis DC01

Exécutez :

```cmd
dcdiag
repadmin /replsummary
```

Puis en PowerShell :

```powershell
Get-ADDomain
Get-ADDomainController -Filter *
Get-ADComputer -Filter * | Select-Object Name,DistinguishedName
```

## Questions à traiter dans le rapport

Répondez clairement aux questions suivantes :

1. Quelle adresse DNS utilise `CLIENT01` ?
2. `CLIENT01` résout-il correctement `dc01.lab.local` ?
3. Quel contrôleur de domaine est trouvé par `nltest` ?
4. Quel contrôleur de domaine a servi à l’ouverture de session ?
5. `dcdiag` remonte-t-il des erreurs critiques ?
6. La réplication entre `DC01` et `DC02` semble-t-elle correcte ?
7. Quelle est votre conclusion sur la santé globale du domaine ?

## Preuves attendues

Vous devez fournir :

- capture ou extrait de `ipconfig /all` ;
- capture ou extrait de `nslookup` ;
- capture ou extrait de `nltest` ;
- capture ou extrait de `dcdiag` ;
- capture ou extrait de `repadmin /replsummary`.

---

# Partie 2 — Création contrôlée d’utilisateurs, groupes et AGDLP

## Objectif

Créer une mini-structure Active Directory propre en respectant le modèle AGDLP.

Rappel :

```text
A  = Account
G  = Global Group
DL = Domain Local Group
P  = Permission
```

Le modèle attendu est :

```text
Utilisateur
   ↓
Groupe Global
   ↓
Groupe Domain Local
   ↓
Permission
```

## Travail demandé sur DC01

1. Créer une OU d’évaluation
2. Créer un utilisateur 
3. Créer un groupe global 
4. Créer un groupe Domain Local 
5. Appliquer le modèle AGDLP


## Vérifications attendues

Exécutez :

```powershell
Get-ADGroupMember "EVAL_<votre_nom>_GG_AUDIT"

Get-ADGroupMember "EVAL_<votre_nom>_DL_SHARE_RW"

Get-ADPrincipalGroupMembership "eval.<votre_nom>" | Select-Object Name
```

## Questions à traiter dans le rapport

1. Pourquoi ne donne-t-on pas directement les permissions à l’utilisateur ?
2. Quelle est la différence entre un groupe global et un groupe Domain Local ?
3. Pourquoi le modèle AGDLP est-il plus maintenable en entreprise ?
4. Quel serait le risque d’ajouter directement un utilisateur sur une ACL de dossier ?

## Preuves attendues

Vous devez fournir :

- preuve de création de l’OU ;
- preuve de création de l’utilisateur ;
- preuve de création des deux groupes ;
- preuve de l’appartenance utilisateur → groupe global ;
- preuve de l’appartenance groupe global → groupe Domain Local.

---

# Partie 3 — Partage réseau contrôlé sur SRV01

## Objectif

Créer un partage SMB de test et appliquer les droits avec le modèle AGDLP.

## Travail demandé sur SRV01

1. Créer le dossier
2. Créer le partage SMB 

> Remarque : sur un système Windows en anglais, le groupe peut s’appeler `LAB\Domain Admins`.

3. Appliquer les droits NTFS :
4. Vérifier les permissions SMB :
5. Vérifier les permissions NTFS :

## Test depuis CLIENT01

Depuis `CLIENT01`, testez l’accès au partage :

```cmd
dir \\SRV01\EVAL_<votre_nom>
```

Connectez-vous avec le compte suivant si nécessaire :

```text
LAB\eval.<votre_nom>
```

Créez un fichier de test dans le partage :

```cmd
echo Test TP AD > \\SRV01\EVAL_<votre_nom>\preuve-acces.txt
```

## Questions à traiter dans le rapport

1. Quelle est la différence entre permission SMB et permission NTFS ?
2. Quelle permission est réellement appliquée si SMB autorise mais NTFS refuse ?
3. Pourquoi utilise-t-on le groupe Domain Local pour porter la permission ?
4. Quelle permission avez-vous donnée au groupe `EVAL_<votre_nom>_DL_SHARE_RW` ?
5. Que signifie `(OI)(CI)(M)` dans la commande `icacls` ?

## Preuves attendues

Vous devez fournir :

- preuve de création du dossier ;
- preuve de création du partage SMB ;
- preuve des permissions SMB ;
- preuve des permissions NTFS ;
- preuve d’accès depuis `CLIENT01` ;
- preuve de création du fichier `preuve-acces.txt`.

---

# Partie 4 — GPO de sécurisation contrôlée

## Objectif

Créer une GPO de test non destructive et vérifier son application.

## GPO à créer

Nom de la GPO :

```text
GPO_EVAL_<votre_nom>_SECURITY
```

La GPO doit appliquer au minimum :

```text
1. Une bannière de connexion
2. L’audit des ouvertures de session
3. Le pare-feu Windows activé sur le profil domaine
```

## Paramètre 1 — Bannière de connexion

Chemin GPO :

```text
Computer Configuration
└── Windows Settings
    └── Security Settings
        └── Local Policies
            └── Security Options
```

Paramètres à configurer :

```text
Interactive logon: Message title for users attempting to log on
Interactive logon: Message text for users attempting to log on
```

Exemple :

```text
Titre : LAB.local - Accès contrôlé
Message : Toute activité est susceptible d'être auditée.
```

## Paramètre 2 — Audit des ouvertures de session

Chemin GPO :

```text
Computer Configuration
└── Policies
    └── Windows Settings
        └── Security Settings
            └── Advanced Audit Policy Configuration
                └── Audit Policies
                    └── Logon/Logoff
```

Activer :

```text
Audit Logon : Success and Failure
```

## Paramètre 3 — Pare-feu Windows

Chemin GPO :

```text
Computer Configuration
└── Windows Settings
    └── Security Settings
        └── Windows Defender Firewall with Advanced Security
```

Activer le pare-feu pour le profil domaine.

## Liaison de la GPO

Lier la GPO à l’OU contenant `CLIENT01`.

Exemple attendu :

```text
OU=Workstations,OU=_Postes,DC=lab,DC=local
```

Vérifiez l’emplacement de `CLIENT01` :

```powershell
Get-ADComputer CLIENT01 -Properties DistinguishedName
```

## Vérification depuis CLIENT01

Forcer l’application des GPO :

```cmd
gpupdate /force
```

Afficher les GPO appliquées :

```cmd
gpresult /r
```

Générer un rapport HTML :

```cmd
mkdir C:\Temp

gpresult /h C:\Temp\rapport-gpo-eval.html
```

Le fichier suivant devra être joint au rendu :

```text
C:\Temp\rapport-gpo-eval.html
```

## Questions à traiter dans le rapport

1. Quelle est la différence entre `Computer Configuration` et `User Configuration` ?
2. Pourquoi une GPO liée à une OU contenant des ordinateurs n’applique-t-elle pas forcément les paramètres utilisateur ?
3. À quoi sert le `Loopback Processing` ?
4. Quels sont les risques d’une GPO mal liée en production ?
5. Pourquoi faut-il contrôler qui peut modifier une GPO ?

## Preuves attendues

Vous devez fournir :

- preuve de création de la GPO ;
- preuve de liaison de la GPO ;
- preuve que `CLIENT01` est dans la bonne OU ;
- extrait ou capture de `gpresult /r` ;
- fichier `rapport-gpo-eval.html` ;
- preuve d’au moins un paramètre appliqué.

---

# Partie 5 — Audit et événements de sécurité

## Objectif

Générer des événements de sécurité contrôlés puis les retrouver dans les journaux Windows.

## Étape 1 — Créer un groupe de simulation sur DC01

```powershell
New-ADGroup `
-Name "EVAL_<votre_nom>_GG_PRIVILEGED_SIMU" `
-GroupScope Global `
-GroupCategory Security `
-Path "OU=EVAL_<votre_nom>,DC=lab,DC=local"
```

## Étape 2 — Ajouter l’utilisateur dans le groupe

```powershell
Add-ADGroupMember `
-Identity "EVAL_<votre_nom>_GG_PRIVILEGED_SIMU" `
-Members "eval.<votre_nom>"
```

## Étape 3 — Retirer l’utilisateur du groupe

```powershell
Remove-ADGroupMember `
-Identity "EVAL_<votre_nom>_GG_PRIVILEGED_SIMU" `
-Members "eval.<votre_nom>" `
-Confirm:$false
```

## Étape 4 — Générer un échec de connexion

Depuis `CLIENT01`, tentez une connexion avec le compte :

```text
LAB\eval.<votre_nom>
```

Utilisez volontairement un mauvais mot de passe.

Attention :

- l’événement `4625` peut apparaître sur `CLIENT01` ;
- sur `DC01`, vous verrez plutôt des événements Kerberos ou NTLM, comme `4771` ou `4776`.

## Event IDs à rechercher sur DC01

| Event ID | Signification |
|---:|---|
| `4720` | Création d’un utilisateur |
| `4728` | Ajout dans un groupe global de sécurité |
| `4729` | Retrait d’un groupe global de sécurité |
| `4738` | Modification d’un compte utilisateur |
| `4771` | Échec de pré-authentification Kerberos |
| `4776` | Échec d’authentification NTLM |
| `4740` | Compte verrouillé |

Commande possible sur `DC01` :

```powershell
Get-WinEvent -FilterHashtable @{
    LogName='Security'
    Id=4720,4728,4729,4738,4771,4776,4740
} -MaxEvents 80 |
Select-Object TimeCreated,Id,Message
```

Pour filtrer plus proprement :

```powershell
Get-WinEvent -FilterHashtable @{
    LogName='Security'
    Id=4720,4728,4729,4738,4771,4776,4740
} -MaxEvents 80 |
Select-Object TimeCreated,Id,@{
    Name='MessageCourt';
    Expression={$_.Message.Substring(0,[Math]::Min(300,$_.Message.Length))}
}
```

## Event ID à rechercher sur CLIENT01

| Event ID | Signification |
|---:|---|
| `4625` | Échec d’ouverture de session |

Commande possible sur `CLIENT01` :

```powershell
Get-WinEvent -FilterHashtable @{
    LogName='Security'
    Id=4625
} -MaxEvents 20 |
Select-Object TimeCreated,Id,Message
```

## Questions à traiter dans le rapport

1. Quel Event ID correspond à la création d’un utilisateur ?
2. Quel Event ID correspond à l’ajout d’un utilisateur dans un groupe global ?
3. Quel Event ID correspond au retrait d’un utilisateur d’un groupe global ?
4. Pourquoi ne voit-on pas forcément `4625` sur le contrôleur de domaine ?
5. Quelle différence faites-vous entre `4625`, `4771` et `4776` ?
6. Pourquoi faut-il surveiller les ajouts dans les groupes sensibles ?
7. Quels événements devraient être envoyés vers un SIEM en production ?

## Preuves attendues

Vous devez fournir :

- preuve de l’événement `4720` ;
- preuve de l’événement `4728` ;
- preuve de l’événement `4729` ;
- preuve d’un échec de connexion ;
- explication de l’emplacement des logs : `CLIENT01` ou `DC01` ;
- mini-timeline des actions réalisées.

Exemple de timeline attendue :

| Heure | Machine | Event ID | Action |
|---|---|---:|---|
| 10:12 | DC01 | 4720 | Création de `eval.dupont` |
| 10:20 | DC01 | 4728 | Ajout dans `EVAL_DUPONT_GG_PRIVILEGED_SIMU` |
| 10:22 | DC01 | 4729 | Retrait du groupe |
| 10:30 | CLIENT01 | 4625 | Mauvais mot de passe |
| 10:30 | DC01 | 4771 | Échec Kerberos |

---

# Partie 6 — Synthèse sécurité

## Objectif

Prendre du recul comme un ingénieur cybersécurité.

## Travail demandé

Rédigez une synthèse courte avec les éléments suivants :

```text
1. Trois risques Active Directory observés ou potentiels dans votre lab
2. Trois mesures de durcissement réalistes
3. Trois commandes indispensables pour diagnostiquer un incident AD
4. Une recommandation sur la surveillance des groupes sensibles
5. Une recommandation sur les comptes de service
6. Une recommandation sur les GPO
```

## Exemples de sujets possibles

Vous pouvez parler de :

```text
- comptes privilégiés ;
- groupes sensibles ;
- modèle AGDLP ;
- mots de passe locaux ;
- comptes de service ;
- GPO mal liées ;
- permissions excessives ;
- absence de centralisation des logs ;
- réplication AD ;
- DNS AD ;
- audit insuffisant ;
- absence de supervision SIEM.
```

---

# Nettoyage recommandé

À la fin du TP, vous pouvez conserver les objets créés si le formateur le demande.

Sinon, vous pouvez nettoyer les ressources créées.

Attention : ne supprimez que vos objets `EVAL_<votre_nom>`.

Exemple :

```powershell
Remove-SmbShare -Name "EVAL_<votre_nom>" -Force
Remove-Item -Path "C:\Shares\EVAL_<votre_nom>" -Recurse -Force
Remove-ADOrganizationalUnit -Identity "OU=EVAL_<votre_nom>,DC=lab,DC=local" -Recursive -Confirm:$false
```

Avant de supprimer, assurez-vous d’avoir toutes les captures et preuves nécessaires.

---

# Barème sur 20

| Partie | Points |
|---|---:|
| Partie 1 — Audit initial AD | 3 |
| Partie 2 — Utilisateurs / groupes / AGDLP | 3 |
| Partie 3 — Partage SMB / NTFS | 3 |
| Partie 4 — GPO de sécurisation | 3 |
| Partie 5 — Audit Event Viewer / Event IDs | 4 |
| Partie 6 — Synthèse sécurité | 2 |
| Qualité du rapport | 2 |
| **Total** | **20** |

---

## Détail du barème

### Partie 1 — Audit initial AD : 3 points

| Critère | Points |
|---|---:|
| Vérification IP/DNS avec `ipconfig /all` | 0.5 |
| Résolution DNS avec `nslookup` | 0.5 |
| Localisation du DC avec `nltest` et `%logonserver%` | 0.5 |
| Analyse de `dcdiag` | 0.75 |
| Analyse de `repadmin /replsummary` | 0.75 |

---

### Partie 2 — Utilisateurs / groupes / AGDLP : 3 points

| Critère | Points |
|---|---:|
| OU et utilisateur créés proprement | 0.75 |
| Groupe global créé et utilisé correctement | 0.75 |
| Groupe Domain Local créé et utilisé correctement | 0.75 |
| Explication correcte du modèle AGDLP | 0.75 |

---

### Partie 3 — Partage SMB / NTFS : 3 points

| Critère | Points |
|---|---:|
| Partage SMB créé correctement | 0.75 |
| Permissions NTFS cohérentes | 0.75 |
| Test d’accès depuis `CLIENT01` | 0.75 |
| Explication SMB vs NTFS | 0.75 |

---

### Partie 4 — GPO de sécurisation : 3 points

| Critère | Points |
|---|---:|
| GPO créée et nommée correctement | 0.5 |
| GPO liée au bon périmètre | 0.75 |
| Paramètres de sécurité pertinents | 0.75 |
| `gpupdate` et `gpresult` utilisés correctement | 0.5 |
| Explication Computer/User/Loopback | 0.5 |

---

### Partie 5 — Audit Event Viewer / Event IDs : 4 points

| Critère | Points |
|---|---:|
| Événement `4720` identifié | 0.75 |
| Événement `4728` ou `4729` identifié | 0.75 |
| Échec de connexion analysé correctement | 0.75 |
| Différence `4625` / `4771` / `4776` expliquée | 0.75 |
| Timeline cohérente | 0.5 |
| Mesures de surveillance proposées | 0.5 |

---

### Partie 6 — Synthèse sécurité : 2 points

| Critère | Points |
|---|---:|
| Risques AD pertinents | 0.5 |
| Mesures de durcissement réalistes | 0.5 |
| Recommandations sur comptes / groupes / GPO | 0.5 |
| Vision cybersécurité professionnelle | 0.5 |

---

### Qualité du rapport : 2 points

| Critère | Points |
|---|---:|
| Rapport clair et structuré | 0.75 |
| Captures et preuves pertinentes | 0.75 |
| Commandes et résultats exploitables | 0.5 |

---

# Conseils méthodologiques

Vous êtes évalués sur votre méthode, pas uniquement sur le résultat final.

Pour chaque action importante, appliquez la logique suivante :

```text
1. Observer
2. Diagnostiquer
3. Corriger ou configurer
4. Vérifier
5. Prouver
6. Expliquer
```

Exemple :

```text
Je ne dis pas seulement "la GPO fonctionne".
Je fournis gpresult, une capture, le périmètre de liaison et une explication.
```

---

# Conclusion attendue

Votre conclusion doit répondre aux questions suivantes :

1. L’environnement AD est-il sain ?
2. Les permissions sont-elles structurées proprement ?
3. Les GPO sont-elles appliquées correctement ?
4. Les événements de sécurité sont-ils retrouvables ?
5. Quelles seraient vos trois priorités de sécurisation en entreprise ?
