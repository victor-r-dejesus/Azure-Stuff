Install-Module ExchangeOnlineManagement
Connect-ExchangeOnline

$mailbox_user = "drusso@thelyst.com"

$SharedMailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {($_.PrimarySmtpAddress -like "*leasing*") -and ($_.RecipientTypeDetails -eq "SharedMailbox")} | Select PrimarySmtpAddress

foreach ($Mailbox in $SharedMailboxes) {
    Add-MailboxPermission -Identity $Mailbox.PrimarySmtpAddress -AccessRights FullAccess -InheritanceType All -AutoMapping:$true -User $mailbox_user
    Add-RecipientPermission -Identity $Mailbox.PrimarySmtpAddress -AccessRights SendAs -Confirm:$false -Trustee $mailbox_user
}