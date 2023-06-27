#define variable for Resource group and location
$resourceGroup =  “LAB06"
$location =  “south india”
$keyvaultName=“webserver"

#Create new RG
New-AzureRmResourceGroup -ResourceGroupName $resourceGroup -Location $location

#Create new Keyvault
New-AzureRmKeyVault -VaultName $keyvaultName  -ResourceGroup $resourceGroup  -Location $location  -EnabledForDeployment

#Define certificate policy
$policy = New-AzureKeyVaultCertificatePolicy  -SubjectName "CN=www.contoso.com"  -SecretContentType "application/x-pkcs12"  -IssuerName Self  -ValidityInMonths 12

#add certificate to azure key vault
Add-AzureKeyVaultCertificate -VaultName webserver  -Name webserver-cert -CertificatePolicy $policy

#Adding certificate to VM

$certURL=(Get-AzureKeyVaultSecret -VaultName $keyvaultName -Name  “webserver-cert").id

$vm=Get-AzureRmVM -ResourceGroupName $resourceGroup -Name  “iis1"

$vaultId=(Get-AzureRmKeyVault -ResourceGroupName $resourceGroup -VaultName $keyVaultName).ResourceId 

$vm = Add-AzureRmVMSecret -VM $vm -SourceVaultId $vaultId -CertificateStore "My" -CertificateUrl $certURL

Update-AzureRmVM -ResourceGroupName $resourceGroup -VM $vm
