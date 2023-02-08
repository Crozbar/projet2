<###########################################
 ###  Création des répertoires partagés  ###
 ###########################################

Ce code crée des répertoires et des partages réseau pour les départements et les employés d'une organisation.
Il lit un fichier CSV nommé "utilisateurs.csv" pour obtenir les noms des départements, en utilisant la commande "import-csv" et en filtrant les valeurs uniques de la colonne "département".
Ensuite, pour chaque département dans la liste, le code crée un répertoire nommé d'après le département sous "C:\partage\Departements".
Le propriétaire et les autorisations du répertoire sont définis en utilisant les commandes "set-NTFSOwner" et "Add-NTFSAccess".
Finalement, le répertoire est partagé en utilisant la commande "New-SmbShare".
Pour chaque employé, le code crée un répertoire sous "C:\partage\Employes", définit le propriétaire et les autorisations, puis partage le répertoire en utilisant les mêmes commandes que pour les départements.
La description du partage est définie en utilisant le nom d'affichage de l'utilisateur obtenu à l'aide de la commande "Get-ADUser".


N.B. 	1. Il est important de vérifier que les noms d'utilisateur et de département sont exacts et correspondent aux noms utilisés dans l'Active Directory.
		2. De plus, vous devriez vous assurer que les chemins de répertoire existent et ont les autorisations appropriées.
		3. Ce script utilise le module ntfssecurity.
#>


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

