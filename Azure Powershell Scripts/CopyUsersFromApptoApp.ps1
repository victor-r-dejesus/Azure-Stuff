#Copies users from a source app to another app

# Connect to Azure AD using Azure AD Powershell
#Connect-AzureAD

#Enter Object ID from source app
$SourceAppObjectID = "c4c2870c-b32e-485e-8639-4df973e02d29"

#Enter Object ID from destination app
$DestAppObjectID = "34791997-3f73-4e22-a938-5b9b2ca18165"

#App Role for a normal user
$app_role_name = "User"

#Pull users from source spp
$SourceAppUsers = Get-AzureADServiceAppRoleAssignment -ObjectId $SourceAppObjectID | Select-Object PrincipalDisplayName

foreach ($SourceAppUser in $SourceAppUsers) {

    $AADuser = Get-AzureADUser -SearchString $SourceAppUser.PrincipalDisplayName
    $AADuser.ObjectID
    $sp = Get-AzureADServicePrincipal -ObjectID $DestAppObjectID
    $appRole = $sp.AppRoles | Where-Object { $_.DisplayName -eq $app_role_name }
    New-AzureADUserAppRoleAssignment -ObjectId $AADUser.ObjectID -PrincipalId $AADUser.ObjectID -ResourceId $DestAppObjectID -Id $appRole.ID
    
}