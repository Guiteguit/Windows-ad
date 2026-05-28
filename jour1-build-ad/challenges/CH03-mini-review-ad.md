# CH03 — Mini review Active Directory

Durée : 45 min

## Situation

Vous intervenez comme auditeur junior sur le domaine `lab.local`.

L'administrateur précédent a terminé les premiers TP rapidement. Votre rôle est de contrôler la qualité de l'organisation Active Directory et d'identifier les écarts qui peuvent compliquer l'administration, l'audit ou la sécurité.

## Objectif

Réaliser une mini revue d'hygiène Active Directory.

Vous devez identifier au moins trois écarts ou améliorations prioritaires concernant :

- organisation des OU ;
- placement des machines ;
- séparation des comptes standards, administrateurs et services ;
- conventions de nommage ;
- groupes inutiles ou mal utilisés ;
- respect du modèle AGDLP ;
- droits directs accordés à des utilisateurs.

## Contraintes

- Ne corrigez pas immédiatement tout ce que vous voyez.
- Commencez par inventorier et qualifier les écarts.
- Classez vos recommandations par priorité.
- Justifiez chaque recommandation avec une preuve.

## Commandes utiles

Sur `DC01` :

```powershell
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
Get-ADComputer -Filter * -Properties DistinguishedName | Select-Object Name, DistinguishedName
Get-ADUser -Filter * -Properties DistinguishedName | Select-Object Name, SamAccountName, DistinguishedName
Get-ADGroup -Filter * -Properties GroupScope | Select-Object Name, GroupScope, DistinguishedName
Get-ADGroupMember "DL_SHARE_RH_RW"
Get-ADGroupMember "DL_SHARE_FINANCE_RW"
Get-ADGroupMember "DL_SHARE_IT_RW"
Get-ADPrincipalGroupMembership "user.rh1" | Select-Object Name
```

Sur `SRV01`, si vous vérifiez les partages :

```powershell
Get-SmbShare
Get-SmbShareAccess -Name "RH"
icacls "C:\Shares\RH"
icacls "C:\Shares\Finance"
icacls "C:\Shares\IT"
icacls "C:\Shares\Commun"
```

## Grille de revue

Répondez aux questions suivantes :

1. Les OU sont-elles lisibles et cohérentes ?
2. `SRV01` est-il dans une OU de serveurs ?
3. `CLIENT01` est-il dans une OU de postes ?
4. Les comptes administrateurs sont-ils séparés des comptes utilisateurs standards ?
5. Les comptes de service sont-ils identifiables ?
6. Les groupes globaux représentent-ils des métiers ou rôles ?
7. Les groupes Domain Local représentent-ils des accès à des ressources ?
8. Les permissions sont-elles données aux groupes `DL_...` plutôt qu'aux utilisateurs ?
9. Existe-t-il des groupes vides, inutiles ou au nom ambigu ?
10. Les conventions de nommage sont-elles respectées ?

## Livrable

Rédigez une note de revue contenant :

- un résumé de l'état observé ;
- au moins trois constats avec preuve technique ;
- un niveau de priorité pour chaque constat : faible, moyen, élevé ;
- une recommandation concrète ;
- les commandes utilisées pour justifier vos constats.

Format attendu :

```text
Constat 1 :
Preuve :
Risque :
Priorité :
Recommandation :
```

## Questions

1. Pourquoi une OU bien organisée facilite-t-elle les GPO ?
2. Pourquoi les comptes administrateurs doivent-ils être séparés des comptes utilisateurs standards ?
3. Pourquoi les groupes vides ou mal nommés posent-ils un problème d'audit ?
4. Quelle différence faites-vous entre corriger vite et corriger proprement ?
