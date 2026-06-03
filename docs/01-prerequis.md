# Prérequis

## Matériel

- 16 Go RAM minimum sur l’hôte ;
- 80 à 150 Go disque ;
- VirtualBox, VMware, Hyper-V ou Proxmox ;
- réseau Host-Only isolé.

## Dimensionnement des VM

Point de vigilance important : `CLIENT01` sous Windows 11 peut prendre 2 à 3 heures à installer et stabiliser selon la machine hôte, le stockage, les mises à jour et l'hyperviseur. Il doit donc être lancé en priorité dès le début de la matinée, voire préparé avant le cours si possible.

Pendant les installations Windows, utilisez de préférence :

```text
DC01      2 vCPU   4 Go RAM
DC02      2 vCPU   4 Go RAM
SRV01     2 vCPU   4 Go RAM
CLIENT01  2 vCPU   4 Go RAM
```

Ce dimensionnement accélère surtout l'installation initiale, les redémarrages et les mises à jour.

Après installation, une fois les systèmes stabilisés et les snapshots de base réalisés, vous pouvez réduire les VM les moins sollicitées :

```text
DC01      2 vCPU   4 Go RAM recommandés
DC02      2 vCPU   2 Go RAM possibles
SRV01     2 vCPU   2 Go RAM possibles
CLIENT01  2 vCPU   4 Go RAM recommandés
```

Remarques :

- `DC01` reste la machine centrale du lab : gardez 4 Go si l'hôte le permet.
- `CLIENT01` sous Windows 11 est souvent la VM la plus lente à installer et à mettre à jour : gardez 4 Go si possible et ne la gardez jamais pour la fin.
- `DC02` et `SRV01` peuvent fonctionner avec 2 Go dans ce lab, surtout après installation des rôles.
- Si l'hôte n'a que 16 Go de RAM, ne démarrez pas forcément toutes les VM en même temps pendant les phases lourdes.

## ISO

- Windows Server 2019 Evaluation ;
- Windows 11 Pro ou Enterprise.

À éviter :

- Windows Home/Famille ;
- DNS 8.8.8.8 / 1.1.1.1 sur les machines du domaine.

## Attention langue française

Dans un lab Windows Server français, le groupe intégré est :

```text
LAB\Admins du domaine
```

et non :

```text
LAB\Domain Admins
```
