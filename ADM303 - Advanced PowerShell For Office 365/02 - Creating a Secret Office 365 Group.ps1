New-UnifiedGroup -DisplayName "SPFESTCHI2019-Reorg Project" `
	-Alias "O365Group-SPFESTCHI2019-ReorgPrivate" `
	-EmailAddresses "SPFESTCHI2019-ReorgPrivate@globomantics.org" `
	-AccessType Private `
	-HiddenGroupMembershipEnabled

Set-UnifiedGroup -Identity "O365Group-SPFESTCHI2019-ReorgPrivate" -HiddenFromAddressListsEnabled $true
