#Install-Module Azure
#Connect-AzureAD

$IGUsers = Get-AzureADUser -All $true | where {($_.CompanyName -eq 'Ignitarium') -and ($_.UserType -eq 'Guest')} | select DisplayName,ObjectID

foreach ($IGUser in $IGUsers){

    Get-AzureADUser -ObjectId $IGUser.ObjectID | select DisplayName | Export-Csv -Path 'C:\IgnitariumMembership.csv' -Append -Force
    Get-AzureADUserMembership -ObjectId $IGUser.ObjectID | select DisplayName | Export-Csv -Path 'C:\IgnitariumMembership.csv' -Append -Force

}