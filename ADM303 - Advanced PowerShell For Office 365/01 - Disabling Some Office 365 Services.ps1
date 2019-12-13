
#Get-AzureADSubscribedSku
$User = Get-AzureADUser -ObjectId Ben@globomantics.org

$Sku = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$Sku.SkuId = "6fd2c87f-b296-42f0-b197-1e91e994b900"

#Get-AzureADSubscribedSku -ObjectId fa17dd8f-73cb-4300-9dfd-265b06fd8901_6fd2c87f-b296-42f0-b197-1e91e994b900 | Select-Object -ExpandProperty ServicePlans

$Sku.DisabledPlans = @("aebd3021-9f8f-4bf8-bbe3-0ed2f4f047a1","7547a3fe-08ee-4ccb-b430-5077c5041653")


$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

$Licenses.AddLicenses = $Sku

Set-AzureADUserLicense -ObjectId $User.ObjectId -AssignedLicenses $Licenses

