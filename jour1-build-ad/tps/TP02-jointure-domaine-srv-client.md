# TP02 — Jointure de SRV01 et CLIENT01 au domaine

Durée : 45 min

## Objectif

Joindre SRV01 et CLIENT01 au domaine `lab.local`.

## SRV01

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.20 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10
Add-Computer -DomainName lab.local -Restart
```

## CLIENT01

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.30 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.56.10
Add-Computer -DomainName lab.local -Restart
```

## Validation

```cmd
whoami
echo %logonserver%
nltest /dsgetdc:lab.local
```

## Question

Que se passe-t-il si CLIENT01 utilise 8.8.8.8 comme DNS ?
