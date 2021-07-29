#This script can enable/disable OWA for users in a tenant.
#While intended for bulk use, it can be modified to find one person.

#Search criteria. Can be a domain name, or user name.
$SearchTerms = "citypipe.com"

#Import module to manage Exchange Online, may need to run in normal PS session.
Import-Module ExchangeOnlineManagement

#Connect to Exchange Online.
Connect-ExchangeOnline

#Looks for users using the search criteria.
$ESPExchUsers = Get-EXOMailbox | Where {$_.UserPrincipalName -match $SearchTerms} | Select UserPrincipalName

foreach ($ESPExchUser in $ESPExchUsers) {

#Sets users found to values $true or $false to enable/disable OWA.
Set-CASMailbox -Identity $ESPExchUser.UserPrincipalName -OWAEnabled $false

}