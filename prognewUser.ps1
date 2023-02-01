
#######################################################
# Jean-Philippe Michaud
# 6 mai 2022
# revision: janvier 2023
#
# Ce script recupere le contenu d'un fichier CSV
# Cree des utilisateurs
#######################################################
Clear-Host

# Importation du fichier CSV
$CSVPath = "utilisateurs.csv"

if (test-path $CSVPath){
	$Userliste = Import-Csv -Path $CSVPath -Delimiter ";"
	}else {
		write-Warning "La destination du fichier .csv est invalide!"
		exit
		}

$userLISTE | % {$_ | Add-Member -NotePropertyMembers @{ Login = $_."first name".substring(0,1)+$_."LAST NAME"} }

$Userliste | % {
  $Nom = $_.LASTNAME
  $Prenom = $_.FIRSTNAME
  $Code = $_.Code
  $Login = $_.Login
  $Parent = $_.DEPARTEMENT
  $motdepasse = $_.motdepasse

#Format des variables ADUser
#Domaine
#$Parent on garde tel quel
$nomDNS = "projet2.local"

#User
$loginName = "$Login"

$codePays = "CA"
$nomPays  = "Canada"
$noPays   = 124

# IMPORTANT: création du compte utilisateur
# Si on ne déclare pas le paramètre -SamAccountName
# Le contenu de -SamAccountName sera le même que le paramètre -Name
$mdp = ConvertTo-SecureString -AsPlainText "$motdepasse" -Force

New-ADUser -Name $loginName `
           -UserPrincipalName "$loginName@$NomDNS" `
           -Path $Parent `
           -GivenName $Prenom `
           -Surname $Nom `
           -office $Code `
           -DisplayName "$Prenom $Nom - $Code" `
           -OtherAttributes @{'c'=$codePays;'co'=$nomPays;'countryCode'=$noPays;}  `
           -AccountPassword $mdp `
           -PasswordNeverExpires $true `
           -Enabled $true

$message = "Fin de la création du compte utilisateur $loginName"
Write-Host $message -ForegroundColor Yellow

}

