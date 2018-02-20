# Use this script to create a new cluster from scratch

param(
   [string] [Parameter(Mandatory = $true)] $Name,
   [string] $Location = "northeurope",
   [string] $AppInsightsKey,
   [string] $ClusterCertPassword = "Password00;",
   [string] $ClientCertPassword = "Password01;",
   [string] $RdpUsername = "clusteradmin",
   [string] $RdpPassword = "Password03;"
)

$ErrorActionPreference = 'Stop'

$ClusterCertFileName = "cluster.pfx"
$ClientCertFileName = "client.pfx"
$ClusterCertDnsName = "cluster" + $Name
$ClientCertDnsName = "client" + $Name

#get current context and fail if not logged into Azure
$RmContext = Get-AzureRmContext
$RmAccountName = $RmContext.Account.Id
if($RmAccountName -eq $null)
{
  Write-Host "[!] You are not logged into Azure. Use Login-AzureRmAccount to log in first and optionally select a subscription" -ForegroundColor Red
  exit
}
Write-Host "You are running as '$RmAccountName'."
Write-Host

# Prepare resource group
Write-Host "[1] Preparing resource group '$Name'..."
$resourceGroup = Get-AzureRmResourceGroup -Name $Name -Location $Location -ErrorAction Ignore
if($resourceGroup -eq $null)
{
  Write-Host "    resource group doesn't exist, creating a new one..."
  $rg = New-AzureRmResourceGroup -Name $Name -Location $Location
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
function CreateCert([string]$CertPassword, [string]$CertFileName, [string]$CertDnsName)
{
   Write-Host "    '$CertDnsName' => $CertFileName..."
   $securePassword = ConvertTo-SecureString $CertPassword -AsPlainText -Force
   $thumbprint = (New-SelfSignedCertificate -DnsName $CertDnsName -CertStoreLocation Cert:\CurrentUser\My -KeySpec KeyExchange).Thumbprint
   $certContent = (Get-ChildItem -Path cert:\CurrentUser\My\$thumbprint)
   $result = Export-PfxCertificate -Cert $certContent -FilePath "$PSScriptRoot\$CertFileName" -Password $securePassword

   $thumbprint
   $certContent
   $securePassword
}

Write-Host "[3] Creating self-signed certificates..."
$clusterCertThumbprint, $clusterCertContent, $clusterCertSecurePassword = `
  CreateCert $ClusterCertPassword $ClusterCertFileName $ClusterCertDnsName
$clientCertThumbprint, $clientCertContent, $clientCertSecurePassword = `
  CreateCert $ClientCertPassword $ClientCertFileName $ClientCertDnsName
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
  adminUserName = $RdpUsername;
  adminPassword = $RdpPassword;
  certificateThumbprint = $clusterCertThumbprint;
  sourceVaultResourceId = $keyVault.ResourceId;
  certificateUrlValue = $importedClusterCert.SecretId;
}

New-AzureRmResourceGroupDeployment `
  -ResourceGroupName $Name `
  -TemplateFile "$PSScriptRoot\SecureCluster.json" `
  -Mode Incremental `
  -TemplateParameterObject $parameters `
  -Verbose `
  -ErrorAction Stop
Write-Host

Write-Host ".all done."