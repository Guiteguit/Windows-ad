Write-Host "=== Check LAB AD ===" -ForegroundColor Cyan
hostname
ipconfig /all
Write-Host "`nDNS DC01" -ForegroundColor Cyan
nslookup dc01.lab.local
Write-Host "`nDécouverte DC" -ForegroundColor Cyan
nltest /dsgetdc:lab.local
Write-Host "`nSession" -ForegroundColor Cyan
whoami
whoami /groups
