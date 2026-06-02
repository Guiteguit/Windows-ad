# Grille d’auto-évaluation étudiant

| Critère | OK/KO | Commentaire |
|---|---|---|
| Domaine `lab.local` fonctionnel | | Preuve : `Get-ADDomain`, `Get-ADDomainController` |
| DNS AD fonctionnel | | Preuve : `nslookup dc01.lab.local`, enregistrements SRV |
| Machines jointes au domaine | | Preuve : `nltest /dsgetdc:lab.local`, `Get-ADComputer` |
| OU cohérentes | | Serveurs, postes, utilisateurs, groupes séparés |
| Utilisateurs créés | | Comptes standards, admin et service identifiables |
| Groupes créés | | `GG_...` et `DL_...` avec scopes corrects |
| AGDLP respecté | | Accounts -> Global Groups -> Domain Local -> Permissions |
| Partages SMB/NTFS validés | | Accès autorisés et refus attendus testés |
| GPO appliquée | | Preuve : `gpresult /r` ou rapport HTML |
| Politique mot de passe/verrouillage | | Preuve : `net accounts`, test verrouillage |
| Audit configuré | | Preuve : `auditpol /get /category:*` |
| Événements retrouvés | | 4720, 4728, 4625 ou équivalents documentés |
| DC02 et réplication validés | | Preuve : `repadmin /replsummary` |
| Rapport clair | | Symptôme, preuve, cause, correction, validation |
