<# 
When Active directory (AD) is configured to store BitLocker keys, and workstation have the WinRM service
enabled, this script will execute remote code to workstations in an OU to backup BitLocker keys to AD.

Change the $SearchBase variable to reflect the correct OU.

Author: Victor DeJesus
with code snippets based from author Martin Pugh (4/15)

#>
[CmdletBinding()]
Param (
    [string]$SearchBase = "OU=Test,DC=Test,DC=com"
)

#Loads AD module
Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Warning "Unable to load Active Directory module because $($Error[0])"; Exit }

#Gets list of PC's in the OU
Write-Verbose "Getting Workstations..." -Verbose
$Computers = Get-ADComputer -Filter * -SearchBase $SearchBase -Properties LastLogonDate

#Adds object properties to variable related to BitLocker recovery.
$Results = ForEach ($Computer in $Computers)
{
    New-Object PSObject -Property @{
        ComputerName = $Computer.Name
        LastLogonDate = $Computer.LastLogonDate 
        BitLockerPasswordSet = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation'" -SearchBase $Computer.distinguishedName -Properties msFVE-RecoveryPassword,whenCreated | Sort whenCreated -Descending | Select -First 1 | Select -ExpandProperty whenCreated
    }
    
}

ForEach ($Result in $Results) {

    #If the BitLocker password property is empty
    If ($Result.BitLockerPasswordSet -eq $null) {

    Write-Host $Result.ComputerName "Does not have a Bitlocker Key in AD"
    
    #Creates a remote session
    $Session = New-PSSession -ComputerName $Result.ComputerName -ErrorAction SilentlyContinue
    
    #If the session was created successfully
    If ($Session -ne $null) {
    Invoke-Command -Session $Session -ScriptBlock {$BLV = Get-BitLockerVolume -MountPoint "C:"}
    Invoke-Command -Session $Session -ScriptBlock {Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId}
    Write-Host "BitLocker Recovery Key copied to AD." -ForegroundColor Green
        }

    #If a session cannot be established
    Else {

    Write-Host "WinRM is not enabled on this PC, or is not accessible on the network. Please verify the PC is on the network, and WinRM is enabled." -ForegroundColor Red

        }
    }

}