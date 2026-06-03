# Jour 1 — Build & administration AD

## Objectif

Construire le socle Active Directory :

- DC01 ;
- domaine `lab.local` ;
- DNS AD ;
- jointure domaine ;
- OU ;
- utilisateurs ;
- groupes ;
- AGDLP ;
- serveur de fichiers ;
- permissions SMB/NTFS.

## Consigne de démarrage du lab

L'installation de `CLIENT01` sous Windows 11 est un point critique du timing. Selon l'hôte, le stockage, les mises à jour et l'hyperviseur, elle peut prendre 2 à 3 heures entre l'installation, la configuration initiale, les redémarrages et la stabilisation.

Ne gardez pas `CLIENT01` pour la fin. Si Windows 11 n'est pas prêt assez tôt, cela peut bloquer ou retarder la jointure domaine, les tests GPO, les tests de partages et une partie importante du setup du TP.

Au début du jour 1, lancez donc les installations en parallèle autant que possible, mais priorisez immédiatement :

```text
1. CLIENT01  Windows 11
2. DC01      Windows Server 2019
3. SRV01     Windows Server 2019
4. DC02      Windows Server 2019, peut être préparé plus tard si besoin
```

Dimensionnement conseillé pendant les installations :

```text
2 vCPU et 4 Go RAM par VM
```

Après installation et snapshot de base, vous pouvez réduire les VM secondaires si l'hôte manque de RAM :

```text
DC01      2 vCPU   4 Go RAM recommandés
DC02      2 vCPU   2 Go RAM possibles
SRV01     2 vCPU   2 Go RAM possibles
CLIENT01  2 vCPU   4 Go RAM recommandés
```

En pratique, gardez `DC01` et `CLIENT01` plus confortables, puis réduisez surtout `DC02` et éventuellement `SRV01`.

## Résultat attendu fin Jour 1

```text
[OK] DC01 AD DS / DNS
[OK] Domaine lab.local
[OK] SRV01 et CLIENT01 joints au domaine
[OK] OU métiers créées
[OK] Utilisateurs et groupes créés
[OK] AGDLP appliqué
[OK] Partages RH, Finance, IT, Commun opérationnels
```
