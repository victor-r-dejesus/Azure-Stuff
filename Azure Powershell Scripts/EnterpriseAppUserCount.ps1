#Connect-AzureAD
#$app_name = "[app display name]"
$app_name = "HappyCo"
$sp = Get-AzureADServicePrincipal -Filter "displayName eq '$app_name'"
$assignments = Get-AzureADServiceAppRoleAssignment -ObjectId $sp.ObjectId -All $true
#$assignments.Count # this row outputs the number of users of the app
$assignments