# Windows Active Directory — M1 Cybersécurité — 2 jours

Module : **04FG05804 — Windows Active Directory**  
Compétence : **RNCP36296BC03 — Superviser le déploiement et l’amélioration des infrastructures**  
Niveau : **M1 / Année 4**

## Objectif

Ce dépôt regroupe les TP étudiants du module sur **2 jours**.  
Le but est de construire, administrer, sécuriser et diagnostiquer un mini SI Windows basé sur Active Directory.

## Structure

```text
windows-ad-m1-cyber-2jours-etudiant/
├── docs/
├── jour1-build-ad/
│   ├── tps/
│   ├── challenges/
│   └── scripts/
├── jour2-gpo-blue-team/
│   ├── tps/
│   ├── challenges/
│   └── scripts/
├── evaluation/
├── livrables/
└── scripts-common/
```

## Architecture de lab

```text
DC01      Windows Server 2019   AD DS / DNS      192.168.56.10
DC02      Windows Server 2019   DC additionnel / DNS  192.168.56.11
SRV01     Windows Server 2019   File Server      192.168.56.20
CLIENT01  Windows 11 Pro        Poste client     192.168.56.30
Réseau    Host-Only             192.168.56.0/24
Domaine   lab.local
NetBIOS   LAB
```

DNS obligatoire pour toutes les machines membres avant l'ajout de `DC02` :

```text
192.168.56.10
```

Après le TP08, `DC02` devient aussi serveur DNS. Les machines membres doivent alors utiliser deux DNS :

```text
DNS préféré   : 192.168.56.10
DNS auxiliaire: 192.168.56.11
```

## Planning global

Le planning ci-dessous est pensé pour une journée de 7h environ, avec des pauses et des temps de débrief.

### Jour 1 — Build & administration AD

- TP00 — Validation du lab : 45 min
- TP01 — Déploiement du domaine Active Directory : 1h15
- TP02 — Jointure SRV01 / CLIENT01 : 1h
- TP03 — OU, utilisateurs, groupes, AGDLP : 1h30
- TP04 — Serveur de fichiers, SMB, NTFS : 1h30
- Challenges : DNS, AGDLP, review AD : 30 à 45 min selon l'avancement

### Jour 2 — GPO, sécurité, audit, réplication

- TP05 — GPO de sécurisation poste : 1h15
- TP06 — Politique mot de passe et verrouillage : 45 min
- TP07 — Audit AD et investigation Blue Team : 1h30
- TP08 — DC02, réplication et disponibilité : 1h15
- TP09 — Maintenance, sauvegarde et dépannage : 45 min
- Challenges : GPO, compte suspect, réplication : 30 à 45 min selon l'avancement

## Priorités pédagogiques

Si le groupe prend du retard, priorisez dans cet ordre :

1. DNS, jointure domaine et validation `nltest`.
2. OU, comptes séparés et modèle AGDLP.
3. Permissions SMB/NTFS avec preuves d'accès et de refus.
4. GPO appliquée et prouvée par `gpresult`.
5. Audit des événements AD sensibles.
6. Réplication DC02 et maintenance.

Les challenges peuvent être utilisés comme exercices complets ou comme démonstrations guidées si le timing devient serré.

## Note formateur

Une relecture pédagogique et des pistes d'amélioration sont disponibles ici :

```text
docs/04-retour-formateur-ameliorations.md
```

## Méthode attendue

Pour chaque incident ou problème :

1. observer le symptôme ;
2. formuler des hypothèses ;
3. vérifier avec des commandes ;
4. corriger proprement ;
5. prouver la correction ;
6. documenter.
