./ADBulkUserFromCSV.ps1 -FilePath <FilePath> -Credential <Username\Password> -AadGroupName <AzureAD-GroupName> -Verbose

-Imports all users in CSV file and creates Azure AD Account (Mandatory).
-Adds user to a group (Optional).
-User asked to change password at first logon.