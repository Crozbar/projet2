<###########################################
 ###  Création des répertoires partagés  ###
 ###########################################

Il doit exister un répertoire partagé par département
Chaque employé doit aussi avoir un disque réseau dans un partage SMB
 
#>

# N.B. Ce script utilise le module ntfssecurity



$Departements=(import-csv -path utilisateurs.csv -delimiter ';').departement | Select-Object -Unique


#création des partages de groupes

foreach ($Departement in $Departements) {
#on crée le répertoire du groupe
	new-item -Type Directory -Name $Departement -Path "C:\partage\Departements\"
	set-NTFSOwner -Path C:\partage\Departements\$Departement\ -Account $Departement
	Add-NTFSAccess -Path C:\partage\Departements\$Departement\ -Account $Departement -AccessRights FullControl


#on partage ce répertoire en passant à la commande new-smbshare une suite de parametres
	$Parametres_departements = @{
	    Name = "$Departement"
	    Path = "C:\partage\Departements\$Departement"
	    FullAccess = "projet2\Administrateur", "projet2\$Departement"
	    Description = "Partage du groupe $Departement"
	}
	New-SmbShare @Parametres_departements
}

#Création des partages pour chaque utilisateurs

#On veux seulement la liste des employés
#On partira donc de la liste de départements qu'on a utilisé précédemment,
#et on l'insère dans le distinguishedname de l'objet Active directory


#liste des utilisateurs pour qui créer les partages
$Utilisateurs=($departements | % { (Get-ADUser -Filter * -SearchBase "OU=$_,DC=projet2,DC=local").Name }) #pour limiter l'itération aux seuls employés, on liste uniquement les CN contenus dans les OU qui nous intéressent



foreach ($Utilisateur in $Utilisateurs) {

#on va chercher le display name de l'utilisateur pour une belle description du partage
$displayname=(get-aduser -identity $utilisateur -properties *).displayname

#Création des répertoires utilisateurs
	new-item -Type Directory -Name $Utilisateur -Path "C:\partage\Employes\"
	set-NTFSOwner -Path C:\partage\Employes\$Utilisateur\ -Account $Utilisateur
	Add-NTFSAccess -Path C:\partage\Employes\$Utilisateur\ -Account $Utilisateur -AccessRights FullControl

#Partage des répertoires utilisateurs

$Parametres_utilisateurs = @{
	    Name = "$Utilisateur"
	    Path = "C:\partage\Employes\$Utilisateur"
	    FullAccess = "projet2\Administrateur", "projet2\$utilisateur"
	    Description = "Partage de l'employé $displayname"
	}
	New-SmbShare @Parametres_utilisateurs

}

