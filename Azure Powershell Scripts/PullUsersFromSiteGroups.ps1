# This script is used to pull users from CA Property SP Groups to the BulkUsers_Group
# in preparation for a bulk import into an SSO Enterprise App requiring all Property users.
$ErrorActionPreference = 'SilentlyContinue'
Connect-AzureAD

$GroupObjectIDDest = "bd52d4de-effc-40b2-9e1e-bc9c36908e14" #The Object ID for the destination group

$Extensions = '*.maint', '*.lm', '*.rm', '*.rd', '*.gm', '*.comm.assist', '*.agm'

foreach ($Extension in $Extensions) {

    $Sites = Get-AzureADGroup -All $true | Where-Object {$_.MailNickName -Like $Extension} #Pulls ObjectID's from groups in wildcard

    foreach ($Site in $Sites) {

        $users = Get-AzureADGroupMember -ObjectId $Site.ObjectId #Pulls users from source group

        foreach ($user in $users) {

            $user
            $AADuser = Get-AzureADUser -ObjectId $user.UserPrincipalName #Extracts ObjectID
            Add-AzureADGroupMember -ObjectId $GroupObjectIDDest -RefObjectId $AADuser.ObjectId -ErrorAction SilentlyContinue #Sets Membership
            
            }
    
    }
}