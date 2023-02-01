#--------------------------------------------------
# Jean-Philippe Michaud
# Mai 2022
# 
# Ce script recupere le contenu d'un fichier CSV
# Cree des utilisateurs et les situe dans leur OU respectif
#--------------------------------------------------
Clear-Host

# Variables statiques
$CSVPath = "utilisateurs.csv"

#Déterminer si l'OU doit être différent de l'attribut Département dans le fichier .csv
#$DCPath = "DC=projet2,DC=LOCAL"


$NomDNS = "projet2.local"

if (test-path $CSVPath){
	$lignes = Import-Csv -Path $CSVPath -Delimiter ";"
	}else {
		write-Warning "La destination du fichier .csv est invalide!"
		exit
		}


$lignes | % {
	$Partiel	= $_.Departement
	$fullPath	= "$Partiel,$DCPath"
	$Nom		= $_.Nom
	$Prenom		= $_.Prenom
	$NomComplet	= "$Prenom $Nom"
	$Mdp		= $_.password
	$SecureMdP	= ($Mdp | ConvertTo-SecureString -AsPlainText -Force)
	$login		= $_.ID
    $UPName 	= "$login@$NomDNS"
	
#On crée un custom-object pour chaque utilisateur à créer:
$NewUserparams = @{
	Name 			= $login
	UserPrincipalname 	= $UPName
	DisplayName		= $NomComplet
	GivenName		= $Prenom
	SurName			= $Nom
	Path 			= $fullPath
	AccountPassword = $SecureMdP
	Enabled 		= $true
	PasswordNeverExpires 	= $true
	}

	New-ADuser @NewUserparams
}
