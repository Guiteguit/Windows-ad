# Cheatsheet commandes

## Réseau / DNS

```cmd
ipconfig /all
nslookup dc01.lab.local
nslookup lab.local
nltest /dsgetdc:lab.local
```

Autoriser le ping ICMPv4 dans le pare-feu Windows :

```powershell
New-NetFirewallRule -DisplayName "LAB - Autoriser ping entrant ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "LAB - Autoriser ping sortant ICMPv4" -Direction Outbound -Protocol ICMPv4 -IcmpType 8 -Action Allow -Profile Any
```

## Domaine

```cmd
whoami
whoami /groups
echo %logonserver%
```

```powershell
Get-ADDomain
Get-ADForest
Get-ADDomainController
Get-ADComputer CLIENT01 -Properties DistinguishedName
```

## GPO

```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\rapport-gpo.html
rsop.msc
```

## IIS / SSO Kerberos

```cmd
setspn -L LAB\SRV01$
setspn -Q HTTP/srv01.lab.local
klist
klist purge
```

```powershell
Install-WindowsFeature Web-Server,Web-Windows-Auth,Web-ASP -IncludeManagementTools
Import-Module WebAdministration
```

## SMB / NTFS

```powershell
Get-SmbShare
Get-SmbShareAccess -Name "RH"
icacls "C:\Shares\RH"
```

## Audit

```cmd
auditpol /get /category:*
```

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4720} -MaxEvents 10
```

## Réplication

```cmd
dcdiag
repadmin /replsummary
repadmin /showrepl
```
