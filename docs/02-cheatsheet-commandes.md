# Cheatsheet commandes

## Réseau / DNS

```cmd
ipconfig /all
nslookup dc01.lab.local
nslookup lab.local
nltest /dsgetdc:lab.local
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
