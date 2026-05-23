# TP04 — Serveur de fichiers et permissions AGDLP

Durée : 1h30

## Objectif

Configurer SRV01 comme serveur de fichiers.

## Créer les dossiers

```powershell
New-Item -Path "C:\Shares\Commun" -ItemType Directory -Force
New-Item -Path "C:\Shares\RH" -ItemType Directory -Force
New-Item -Path "C:\Shares\Finance" -ItemType Directory -Force
New-Item -Path "C:\Shares\IT" -ItemType Directory -Force
```

## Installer le rôle

```powershell
Install-WindowsFeature FS-FileServer -IncludeManagementTools
```

## Créer les partages

```powershell
New-SmbShare -Name "Commun" -Path "C:\Shares\Commun" -FullAccess "LAB\Admins du domaine" -ReadAccess "LAB\DL_SHARE_COMMUN_RO"
New-SmbShare -Name "RH" -Path "C:\Shares\RH" -FullAccess "LAB\Admins du domaine" -ChangeAccess "LAB\DL_SHARE_RH_RW"
New-SmbShare -Name "Finance" -Path "C:\Shares\Finance" -FullAccess "LAB\Admins du domaine" -ChangeAccess "LAB\DL_SHARE_FINANCE_RW"
New-SmbShare -Name "IT" -Path "C:\Shares\IT" -FullAccess "LAB\Admins du domaine" -ChangeAccess "LAB\DL_SHARE_IT_RW"
```

## Permissions NTFS exemple RH

```powershell
icacls "C:\Shares\RH" /inheritance:r
icacls "C:\Shares\RH" /grant "LAB\Admins du domaine:(OI)(CI)(F)"
icacls "C:\Shares\RH" /grant "SYSTEM:(OI)(CI)(F)"
icacls "C:\Shares\RH" /grant "LAB\DL_SHARE_RH_RW:(OI)(CI)(M)"
```

Faire l’équivalent pour Finance, IT, Commun.

## Tests

Avec `LAB\user.rh1` :

```text
\\SRV01\RH        écriture OK
\\SRV01\Finance   refusé
\\SRV01\Commun    lecture OK, écriture refusée
```

## Livrables

- `Get-SmbShare`
- `Get-SmbShareAccess -Name "RH"`
- `icacls "C:\Shares\RH"`
- capture accès RH OK
- capture accès Finance refusé
