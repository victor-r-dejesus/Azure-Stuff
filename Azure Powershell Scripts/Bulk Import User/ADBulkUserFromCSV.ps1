[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = 'CSV file')]
    [Alias('CSVFile')]
    [string]$FilePath,
    [Parameter(Position = 1, Mandatory = $false, HelpMessage = 'Put Credentials')]
    [Alias('Cred')]
    [PSCredential]$Credential,
    #MFA Account for Azure AD Account
    [Parameter(Position = 2, Mandatory = $false, HelpMessage = 'MFA enabled?')]
    [Alias('2FA')]
    [Switch]$MFA,
    [Parameter(Position = 3, Mandatory = $false, HelpMessage = 'Azure AD Group Name')]
    [Alias('AADGN')]
    [string]$AadGroupName
)
Function Install-AzureAD {
    Set-PSRepository -Name PSGallery -Installation Trusted -Verbose:$false
    Install-Module -Name AzureAD -AllowClobber -Verbose:$false
}

Try {
    $CSVData = @(Import-CSV -Path $FilePath -ErrorAction Stop)
    Write-Verbose "Successfully imported entries from $FilePath"
    Write-Verbose "Total no. of entries in CSV are : $($CSVData.count)"
} 
Catch {
    Write-Verbose "Failed to read from the CSV file, PS  $FilePath Exiting!"
    
    Break
}

Try {
    Write-Verbose "Connecting to Azure AD..."
    if ($MFA) {
        Connect-AzureAD -ErrorAction Stop | Out-Null
    }
    Else {
        Connect-AzureAD -Credential $Credential -ErrorAction Stop | Out-Null
    }
}
Catch {
    Write-Verbose "Cannot connect to Azure AD. Please check your credentials. Exiting!"
    Break
}

Foreach ($Entry in $CSVData) {
    # Verify that mandatory properties are defined for each object
    $DisplayName = $Entry.DisplayName
    $MailNickName = $Entry.MailNickName
    $UserPrincipalName = $Entry.UserPrincipalName
    $Password = $Entry.PasswordProfile
    
    If (!$DisplayName) {
        Write-Warning '$DisplayName is not provided. Continue to the next record'
        Continue
    }

    If (!$MailNickName) {
        Write-Warning '$MailNickName is not provided. Continue to the next record'
        Continue
    }

    If (!$UserPrincipalName) {
        Write-Warning '$UserPrincipalName is not provided. Continue to the next record'
        Continue
    }

    If (!$Password) {
        Write-Warning "Password is not provided for $DisplayName in the CSV file!"
        $Password = Read-Host -Prompt "Enter desired Password" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = $Password
        $PasswordProfile.EnforceChangePasswordPolicy = 1
        $PasswordProfile.ForceChangePasswordNextLogin = 1
    }
    Else {
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = $Password
        $PasswordProfile.EnforceChangePasswordPolicy = 1
        $PasswordProfile.ForceChangePasswordNextLogin = 1
    }   
    
    Try {    
        New-AzureADUser -DisplayName $DisplayName `
            -AccountEnabled $true `
            -MailNickName $MailNickName `
            -UserPrincipalName $UserPrincipalName `
            -PasswordProfile $PasswordProfile `
            -City $Entry.City `
            -Country $Entry.Country `
            -Department $Entry.Department `
            -JobTitle $Entry.JobTitle `
            -Mobile $Entry.Mobile | Out-Null
        Write-Verbose "$DisplayName : AAD Account is created successfully!"     
        If ($AadGroupName) {
            Try {   
                $AadGroupID = Get-AzureADGroup -SearchString "$AadGroupName"
            }
            Catch {
                Write-Error "$AadGroupName : does not exist. $_"
                Break
            }
        $ADuser = Get-AzureADUser -ObjectId "$UserPrincipalName"
        Add-AzureADGroupMember -ObjectId $AadGroupID.ObjectID -RefObjectId $ADuser.ObjectID 
        Write-Verbose "Assigning the user $DisplayName to Azure AD Group $AadGroupName"    
        }         
    } 
    Catch {
        Write-Error "$DisplayName : Error occurred $_"
    }
}
