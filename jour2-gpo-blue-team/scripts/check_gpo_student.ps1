gpupdate /force
gpresult /r
if (-not (Test-Path C:\Temp)) { New-Item -Path C:\Temp -ItemType Directory | Out-Null }
gpresult /h C:\Temp\rapport-gpo.html
Write-Host "Rapport : C:\Temp\rapport-gpo.html" -ForegroundColor Green
