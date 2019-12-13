$Office365Groups = Get-UnifiedGroup
foreach ($Group in $Office365Groups)
{
	$SPSiteLogs =  $null
	$DocLibLogs =  $null
	$SPSite = $group.SharePointSiteUrl
	$SPLib = $group.SharePointDocumentsUrl
	$SPSiteLogs = Search-UnifiedAuditLog -StartDate ((get-date).adddays(-45)) -EndDate (Get-Date) -ObjectId $SPSite | Sort-Object -Descending -Property CreationDate | Select-Object -First 1
	$DocLibLogs = Search-UnifiedAuditLog -StartDate ((get-date).adddays(-45)) -EndDate (Get-Date) -ObjectId $SPLib | Sort-Object -Descending -Property CreationDate | Select-Object -First 1
	$Mailbox = Get-MailboxFolderStatistics -Identity $Group.Alias -IncludeOldestAndNewestITems -FolderScope Inbox
	$LastConversation = $Mailbox.NewestItemReceivedDate

	if ($SPSiteLogs -or $DocLibLogs -or  $LastConversation -gt ((get-date).adddays(-45)))
	{
		Write-Host "The following Group" $Group.PrimarySmtpAddress " Is Still Active" -ForegroundColor Green
	}
	else
	{
		Write-Host "The following Group" $Group.PrimarySmtpAddress " SharePoint Site or Mailbox haven't been used in the last 45 days" -ForegroundColor Magenta
	}
}


