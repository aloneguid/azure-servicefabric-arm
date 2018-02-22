# Use this script to create a new cluster from scratch

param(
   [string] [Parameter(Mandatory = $true)] $Name,
   [string] $Location = "northeurope"
)

$ErrorActionPreference = 'Stop'
$t = [Reflection.Assembly]::LoadWithPartialName("System.Web")

$ClusterCertFileName = "cluster.pfx"
$ClientCertFileName = "client.pfx"
$ClusterCertDnsName = "cluster" + $Name
$ClientCertDnsName = "client" + $Name

#get current context and fail if not logged into Azure
$RmContext = Get-AzureRmContext
if($RmContext.Account -eq $null) {
  Write-Host "[!] You are not logged into Azure. Use Login-AzureRmAccount to log in first and optionally select a subscription" -ForegroundColor Red
  exit
}
$RmAccountName = $RmContext.Account.Id
Write-Host "You are running as '$RmAccountName'."
Write-Host

# Prepare resource group
Write-Host "[1] Preparing resource group '$Name'..."
$resourceGroup = Get-AzureRmResourceGroup -Name $Name -Location $Location -ErrorAction Ignore
if($resourceGroup -eq $null)
{
  Write-Host "    resource group doesn't exist, creating a new one..."
  $resourceGroup = New-AzureRmResourceGroup -Name $Name -Location $Location
}
else
{
  Write-Host "    resource group already exists."
}
# Just in case re-set the policy
Write-Host

# properly create a new Key Vault
# KV must be enabled for deployment (last parameter)
Write-Host "[2] Preparing Key Vault '$Name'..."
$keyVault = Get-AzureRmKeyVault -VaultName $Name -ErrorAction Ignore
if($keyVault -eq $null)
{
  Write-Host "    key vault doesn't exist, creating a new one..."
  $keyVault = New-AzureRmKeyVault -VaultName $Name -ResourceGroupName $Name -Location $Location -EnabledForDeployment
}
else
{
  Write-Host "    key vault already exists."
}
Write-Host "    setting access policy for '$RmAccountName' to allow certificate import..."
Set-AzureRmKeyVaultAccessPolicy -VaultName $Name -ResourceGroupName $Name -PermissionsToCertificates all -EmailAddress $RmAccountName
Write-Host
# note that KeyVault policies are separate from RBAC, therefore we need to explicitly grant permissions to performn any actions

# self-signed certificate
function CreateCert([string]$CertFileName, [string]$CertDnsName)
{
   Write-Host "    '$CertDnsName' => $CertFileName..."
   $CertPassword = [System.Web.Security.Membership]::GeneratePassword(15,2)
   $securePassword = ConvertTo-SecureString $CertPassword -AsPlainText -Force
   $thumbprint = (New-SelfSignedCertificate -DnsName $CertDnsName -CertStoreLocation Cert:\CurrentUser\My -KeySpec KeyExchange).Thumbprint
   $certContent = (Get-ChildItem -Path cert:\CurrentUser\My\$thumbprint)
   $t = Export-PfxCertificate -Cert $certContent -FilePath "$PSScriptRoot\$CertFileName" -Password $securePassword

   $thumbprint
   $certContent
   $securePassword
}

Write-Host "[3] Creating self-signed certificates..."
$clusterCertThumbprint, $clusterCertContent, $clusterCertSecurePassword = `
  CreateCert $ClusterCertFileName $ClusterCertDnsName
$clientCertThumbprint, $clientCertContent, $clientCertSecurePassword = `
  CreateCert $ClientCertFileName $ClientCertDnsName
Write-Host "        cluster thumbprint: $clusterCertThumbprint"
Write-Host "        client  thumbprint: $clientCertThumbprint"
Write-Host

Write-Host "[4] Importing certificates into Key Vault..."
Write-Host "    importing cluster certificate..."
$importedClusterCert = Import-AzureKeyVaultCertificate `
  -VaultName $Name -Name $ClusterCertDnsName -FilePath "$PSScriptRoot\$ClusterCertFileName" -Password $clusterCertSecurePassword
Write-Host "    importing client certificate..."
$importedClientCert = Import-AzureKeyVaultCertificate `
  -VaultName $Name -Name $ClientCertDnsName -FilePath "$PSScriptRoot\$ClientCertFileName" -Password $clientCertSecurePassword
Write-Host

# cluster location is taken from resource group

Write-Host "[5] Deploying cluster..."
$parameters = @{
  namePart = $Name;
  certificateThumbprint = $clusterCertThumbprint;
  sourceVaultResourceId = $keyVault.ResourceId;
  certificateUrlValue = $importedClusterCert.SecretId;
}

New-AzureRmResourceGroupDeployment `
  -ResourceGroupName $Name `
  -TemplateFile "$PSScriptRoot\win.json" `
  -Mode Incremental `
  -TemplateParameterObject $parameters `
  -Verbose
Write-Host

Write-Host ".all done."