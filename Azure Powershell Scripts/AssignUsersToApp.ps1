# Used to pull users from CA's BulkUsers_Group into an SSO Enterprise App.
# Connect to Azure AD using Azure AD Powershell
Connect-AzureAD

# Assign the global values to the variables for the script.
$GroupObjectID = "bd52d4de-effc-40b2-9e1e-bc9c36908e14" #The Object ID for the Azure Security Group
$app_name = "SAP Concur Travel and Expense" #Display name of the App
$app_role_name = "User" #App Role for a normal user
$users = Get-AzureADGroupMember -ObjectId $GroupObjectID -All $true | select userPrincipalName
$username = $users

foreach ($user in $users) {

# Get the user to assign, and the service principal for the app to assign to
$AADuser = Get-AzureADUser -ObjectId $user.UserPrincipalName
$sp = Get-AzureADServicePrincipal -Filter "displayName eq '$app_name'"
$appRole = $sp.AppRoles | Where-Object { $_.DisplayName -eq $app_role_name }

# Assign the user to the app role
New-AzureADUserAppRoleAssignment -ObjectId $AADuser.ObjectId -PrincipalId $AADuser.ObjectId -ResourceId $sp.ObjectId -Id $appRole.Id
}