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
DC01      Windows Server 2022   AD DS / DNS      192.168.56.10
DC02      Windows Server 2022   DC secondaire    192.168.56.11
SRV01     Windows Server 2022   File Server      192.168.56.20
CLIENT01  Windows 11 Pro        Poste client     192.168.56.30
Réseau    Host-Only             192.168.56.0/24
Domaine   lab.local
NetBIOS   LAB
```

DNS obligatoire pour toutes les machines membres :

```text
192.168.56.10
```

## Planning global

### Jour 1 — Build & administration AD

- TP00 — Validation du lab
- TP01 — Déploiement du domaine Active Directory
- TP02 — Jointure SRV01 / CLIENT01
- TP03 — OU, utilisateurs, groupes, AGDLP
- TP04 — Serveur de fichiers, SMB, NTFS
- Challenges : DNS, AGDLP, review AD

### Jour 2 — GPO, sécurité, audit, réplication

- TP05 — GPO de sécurisation poste
- TP06 — Politique mot de passe et verrouillage
- TP07 — Audit AD et investigation Blue Team
- TP08 — DC02, réplication et disponibilité
- TP09 — Maintenance, sauvegarde et dépannage
- Challenges : GPO, compte suspect, réplication

## Méthode attendue

Pour chaque incident ou problème :

1. observer le symptôme ;
2. formuler des hypothèses ;
3. vérifier avec des commandes ;
4. corriger proprement ;
5. prouver la correction ;
6. documenter.
