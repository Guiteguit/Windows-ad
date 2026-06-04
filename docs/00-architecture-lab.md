# Architecture du lab

## Topologie

```text
Réseau LAB : 192.168.56.0/24

DC01      AD DS / DNS         192.168.56.10
DC02      DC additionnel / DNS  192.168.56.11
SRV01     File Server         192.168.56.20
CLIENT01  Windows 11 Pro      192.168.56.30
```

## Domaine

```text
Domaine DNS : lab.local
NetBIOS     : LAB
```

## Snapshots recommandés

```text
SNAP_00_BASE_OS
SNAP_01_DC01_READY
SNAP_02_DOMAIN_JOINED_STRUCTURE_READY
SNAP_03_FILESERVER_AGDLP_READY
SNAP_04_GPO_SECURITY_READY
SNAP_05_AUDIT_BLUE_TEAM_READY
SNAP_06_DC02_REPLICATION_READY
```
