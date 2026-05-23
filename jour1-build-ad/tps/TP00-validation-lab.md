# TP00 — Validation du lab

Durée : 30 min

## Objectif

Valider que les VM et le réseau sont prêts.

## Travail demandé

Sur chaque VM :

```cmd
hostname
ipconfig /all
```

Depuis SRV01 et CLIENT01 :

```cmd
ping 192.168.56.10
```

## IP attendues

```text
DC01      192.168.56.10
DC02      192.168.56.11
SRV01     192.168.56.20
CLIENT01  192.168.56.30
```

## Livrable

Capture de `ipconfig /all` sur DC01, SRV01 et CLIENT01.

## Question

Pourquoi une IP fixe est-elle indispensable pour un contrôleur de domaine ?
