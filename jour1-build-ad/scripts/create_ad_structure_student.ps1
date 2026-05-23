$Password = ConvertTo-SecureString "P@ssw0rd-2026!" -AsPlainText -Force
"_Admins","_Serveurs","_Postes","_Utilisateurs","_Groupes","_GPO" | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path "DC=lab,DC=local" -ErrorAction SilentlyContinue
}
New-ADOrganizationalUnit -Name "IT" -Path "OU=_Utilisateurs,DC=lab,DC=local" -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "RH" -Path "OU=_Utilisateurs,DC=lab,DC=local" -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Finance" -Path "OU=_Utilisateurs,DC=lab,DC=local" -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Direction" -Path "OU=_Utilisateurs,DC=lab,DC=local" -ErrorAction SilentlyContinue
Write-Host "Structure de base créée. Compléter selon le TP." -ForegroundColor Green
