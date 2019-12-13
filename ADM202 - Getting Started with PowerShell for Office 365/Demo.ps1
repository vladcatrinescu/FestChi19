$cred = Get-Credential

#AzureAD

Connect-AzureAD -Credential $cred
Get-AzureADUser
Get-AzureADUser | Where {$_.UserType -eq "Member"}
Get-AzureADUser | Where { $_.Department -eq "Research"} 
Get-AzureADUser -ObjectId jeff.collins@globomantics.org | Format-List

#Creating New Users

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "SPFESTCHI2019!@"
$PasswordProfile.ForceChangePasswordNextLogin = $true

New-AzureADUser -GivenName "Ben" `
				-Surname "King" `
				-DisplayName "Ben King" `
				-UserPrincipalName "Ben@globomantics.org" `
				-MailNickName "Ben" `
				-AccountEnabled $true `
				-PasswordProfile $PasswordProfile `
				-JobTitle "IT Manager" `
				-Department "IT"
				
Set-AzureADUserManager -ObjectId Ben@globomantics.org -RefObjectId (Get-AzureADUser -ObjectId vlad@globomantics.org).ObjectId 


#Viewing Licenses

Get-AzureADSubscribedSku 
Get-AzureADSubscribedSku | Select-Object  -Property ObjectId, SkuPartNumber, ConsumedUnits -ExpandProperty PrepaidUnits

Get-AzureADSubscribedSku -ObjectId fa17dd8f-73cb-4300-9dfd-265b06fd8901_6fd2c87f-b296-42f0-b197-1e91e994b900 | Select-Object -ExpandProperty ServicePlans

#Setting a License to a User
$User = Get-AzureADUser -ObjectId Ben@globomantics.org

Set-AzureADUser -ObjectId $User.ObjectId -UsageLocation CA

$Sku = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$Sku.SkuId = "6fd2c87f-b296-42f0-b197-1e91e994b900"


$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenseS

$Licenses.AddLicenses = $Sku

Set-AzureADUserLicense -ObjectId $User.ObjectId -AssignedLicenses $Licenses

#SharePoint

Connect-SPOService -Url https://globomanticsorg-admin.sharepoint.com/ -Credential $cred
New-SPOSite -Url https://globomanticsorg.sharepoint.com/teams/SPFESTCHI2019 -Owner vlad@globomantics.org -StorageQuota 1024 -LocaleID 1033 -Template "STS#3" -Title "IT Team Site"


Remove-SPOSite `
    -Identity https://globomanticsorg.sharepoint.com/teams/SPFESTCHI2019 `
    -Confirm:$false
	
Get-SPODeletedSite 

Restore-SPODeletedSite -Identity https://globomanticsorg.sharepoint.com/teams/SPFESTCHI2019

$site = Get-SPOSite -Identity https://globomanticsorg.sharepoint.com/teams/SPFESTCHI2019

Set-SPOSite $site -Title "Information Technology Team Site"

Set-SPOSite $site -SharingCapability ExternalUserAndGuestSharing

#Disabled							Don't allow sharing outside your organization
#ExternalUserSharingOnly			Allow external users who accept sharing invitations and sign in as authenticated users
#ExternalUserAndGuestSharing		Allow sharing with all external users, and by using anonymous access links
#ExistingExternalUserSharingOnly	Allow sharing only with the external users that already exist in your organization's directory

Get-SPOSite | Where {$_.SharingCapability -eq "ExternalUserAndGuestSharing"} | Select Url

$Groups = Get-SPOSiteGroup -Site $site
foreach ($Group in $Groups)
    {
        Write-Host $Group.Title -ForegroundColor "Blue"
        Get-SPOSiteGroup -Site $site -Group $Group.Title |    Select-Object -ExpandProperty Users
        Write-Host
    }


Set-SPOBrowserIdleSignOut `
    -Enabled $true `
    -WarnAfter (New-TimeSpan -Minutes 5) `
    -SignOutAfter (New-TimeSpan -Minutes 10)


#SPO PNP
Connect-PnPOnline -Url https://globomanticsorg.sharepoint.com/ -Credentials $cred

New-PnPWeb -Url Managers `
	-Title "Managers Only Site" `
	-Template "STS#0" `
	-BreakInheritance `
	-Locale 1033 `
	-Description "Use this subsite to communication about sensitive information between managers"

New-PnPList -Title "Team Announcements" -Template Announcements
Get-PnPList


#Teams
Connect-MicrosoftTeams -Credential $cred

Get-Team

$team = Get-Team -GroupId 1d6d3805-8cfe-4422-9f14-a839e64a303b

Set-Team -GroupId $team.GroupId -AllowUserEditMessages $false

Get-TeamChannel -GroupId $team.groupid

New-TeamChannel -GroupId $team.groupid -DisplayName "SPFESTCHI2019" -MembershipType Private
#https://docs.microsoft.com/en-us/powershell/module/teams/new-teamchannel?view=teams-ps 

Set-TeamChannel -GroupId $team.GroupId  -CurrentDisplayName Channel3 -NewDisplayName Channel4           

#Commerce

Connect-MSCommerce
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase

$product = Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | where {$_.ProductName -match 'Power Automate'}
Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $product.ProductID -Enabled $false

$Products = Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase
foreach ($Product in $Products){
    Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $Product.ProductID -Enabled $false
}

Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase
