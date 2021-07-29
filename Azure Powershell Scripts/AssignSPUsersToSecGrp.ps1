# This script is used to pull users from CA Corp's sec.grp.sp.corp.staff.all to the BulkUsers_Group
# in preparation for a bulk import into an SSO Enterprise App requiring all corporate users.
$ErrorActionPreference = 'SilentlyContinue'
Connect-AzureAD

$GroupObjectIDSource = "06a9d52f-f7e3-47cf-b515-6005040ba85f" #The Object ID for the source SP group
$GroupObjectIDDest = "bd52d4de-effc-40b2-9e1e-bc9c36908e14" #The Object ID for the destination group
$users = Get-AzureADGroupMember -ObjectId $GroupObjectIDSource | select userPrincipalName #Pulls users from source group

foreach ($user in $users) {

$AADuser = Get-AzureADUser -ObjectId $user.UserPrincipalName #Extracts ObjectID
Add-AzureADGroupMember -ObjectId $GroupObjectIDDest -RefObjectId $AADuser.ObjectId -ErrorAction SilentlyContinue ; Write-Host $user.UserPrincipalName #Sets Membership

}