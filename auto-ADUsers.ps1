#--------------------------------------------------
# Jean-Philippe Michaud
# Projet2
# 
# Ce script récupère le contenu d'un fichier CSV
# On crée des unité organisationelles en fonction du nom des départements
# On crée des groupes en fonction du nom des départements
# On crée des utilisateurs et les situe dans leur OU respective
# On ajoute les utilisateurs à leur groupe respectif
#--------------------------------------------------
Clear-Host

#total d'utilisateurs
$total=0

# Variables statiques
$CSVPath = "utilisateurs.csv"

#IMPORTANT
#Déterminer si l'OU doit être différent de l'attribut Département dans le fichier .csv
$DCPath = "DC=projet2,DC=LOCAL"
$codePays = "CA"
$nomPays  = "Canada"
$noPays   = 124

$NomDNS = "projet2.local"

if (test-path $CSVPath){
	$userListe = Import-Csv -Path $CSVPath -Delimiter ";"
	}else {
		write-Warning "La destination du fichier .csv est invalide!"
		sleep 2
		exit
		}

#creation des OU
#On fait une liste unique à partir des départements
[array]$listeOU=($userListe | % {$_.Departement } | Select-Object -Unique)

#En boucle, on crée une OU et un groupe du même nom
foreach ($OU in $listeOU) {
	New-ADOrganizationalUnit -Name $OU -Path $DCPath -ProtectedFromAccidentalDeletion $False
	New-ADGroup -Name "$OU" -SamAccountName "$OU" -GroupCategory "distribution" -GroupScope Global -DisplayName "$OU" -Path "CN=Users,DC=projet2,DC=local" -Description "Les membres de ce groupe travaillent dans le département  $OU"
}

#Création des logins utilisateurs
$userLISTE | % {$_ | Add-Member -NotePropertyMembers @{ Login = $_."first name".substring(0,1)+$_."LAST NAME"} }

$userListe | % {
	$Partiel	= $_.Departement
	$fullPath	= "OU=$Partiel,$DCPath"
	$Nom		= $_."Last Name"
	$Prenom		= $_."First Name"
	$NomComplet	= "$Prenom $Nom"
	$Mdp		= $_.Password
	$SecureMdP	= ($Mdp | ConvertTo-SecureString -AsPlainText -Force)
	$userlogin	= $_.Login
    $UPName 	= "$userlogin@projet2"
	
#On crée un custom-object qui assigne chaque paramètre pour l'utilisateur à créer:

$NewUserparams = @{
	Name 			= $userlogin
	SamAccountname		= $userlogin
	UserPrincipalname 	= $UPName
	DisplayName		= $NomComplet
	GivenName		= $Prenom
	SurName			= $Nom
	Office			= $Partiel
	Path 			= $fullPath
	AccountPassword 	= $SecureMdP
	Enabled 		= $true
	PasswordNeverExpires 	= $true
#	Ajouter les  OtherAttributes @{'c'=$codePays;'co'=$nomPays;'countryCode'=$noPays;}
	}

#	On crée l'utilisateur, puis on le rend membre du groupe approprié
	New-ADuser @NewUserparams
	Add-AdGroupMember -Identity $Partiel -Members $UserLogin
	$message = "Le compte utilisateur $userlogin a été créé"
	$total++
	Write-Host $message -ForegroundColor Yellow
	
}
write-host $total utilisateurs créés
