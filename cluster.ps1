# Use this script to create a new cluster from scratch

param(
   [string] [Parameter(Mandatory = $true)] $Name,
   [string] $Location = "northeurope",
   [switch] $DeployOMS = $false,
   [switch] $MiniCluster = $false
)

# deploy OMS workspace: https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-service-fabric-azure-resource-manager

$ErrorActionPreference = 'Stop'
$t = [Reflection.Assembly]::LoadWithPartialName("System.Web")

$ClusterCertFileName = "cluster-$Name.pfx"
$ClientCertFileName = "client-$Name.pfx"
$ClusterCertDnsName = "cluster" + $Name
$ClientCertDnsName = "client" + $Name

# get current context and fail if not logged into Azure
$RmContext = Get-AzContext
if($null -eq $RmContext.Account) {
  Write-Host "[!] You are not logged into Azure. Use Login-AzureRmAccount to log in first and optionally select a subscription" -ForegroundColor Red
  exit
}
$RmAccountName = $RmContext.Account.Id
Write-Host "You are running as '$RmAccountName'."
Write-Host

# Prepare resource group
Write-Host "[1] Preparing resource group '$Name'..."
$resourceGroup = Get-AzResourceGroup -Name $Name -Location $Location -ErrorAction Ignore
if($null -eq $resourceGroup)
{
  Write-Host "    resource group doesn't exist, creating a new one..."
  $resourceGroup = New-AzResourceGroup -Name $Name -Location $Location
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
$keyVault = Get-AzKeyVault -VaultName $Name -ErrorAction Ignore
if($keyVault -eq $null)
{
  Write-Host "    key vault doesn't exist, creating a new one..."
  $keyVault = New-AzKeyVault -VaultName $Name -ResourceGroupName $Name -Location $Location -EnabledForDeployment
}
else
{
  Write-Host "    key vault already exists."
}
Write-Host "    setting access policy for '$RmAccountName' to allow certificate import..."
Set-AzKeyVaultAccessPolicy -VaultName $Name -ResourceGroupName $Name -PermissionsToCertificates get,import,list -EmailAddress $RmAccountName
Write-Host
# note that KeyVault policies are separate from RBAC, therefore we need to explicitly grant permissions to performn any actions

# self-signed certificate

function CreateSelfSignedCertificate([string]$DnsName)
{
    Write-Host "Creating self-signed certificate with dns name $DnsName"
    
    $filePath = "$PSScriptRoot\$DnsName.pfx"

    Write-Host "  generating password... " -NoNewline
    $certPassword = "123"
    Write-Host "$certPassword"

    Write-Host "  generating certificate... " -NoNewline
    $securePassword = ConvertTo-SecureString $certPassword -AsPlainText -Force
    $thumbprint = (New-SelfSignedCertificate -DnsName $DnsName -CertStoreLocation Cert:\CurrentUser\My -KeySpec KeyExchange).Thumbprint
    Write-Host "$thumbprint."
    
    Write-Host "  exporting to $filePath..."
    $certContent = (Get-ChildItem -Path cert:\CurrentUser\My\$thumbprint)
    $t = Export-PfxCertificate -Cert $certContent -FilePath $filePath -Password $securePassword
    Set-Content -Path "$PSScriptRoot\$DnsName.thumb.txt" -Value $thumbprint
    Set-Content -Path "$PSScriptRoot\$DnsName.pwd.txt" -Value $certPassword
    Write-Host "  exported."

    $thumbprint
    $certPassword
    $filePath
}

function EnsureSelfSignedCertificate([string]$KeyVaultName, [string]$CertName)
{
    $localPath = "$PSScriptRoot\$CertName.pfx"
    $existsLocally = Test-Path $localPath

    # create or read certificate
    if($existsLocally) {
        Write-Host "Certificate exists locally."
        $thumbprint = Get-Content "$PSScriptRoot\$Certname.thumb.txt"
        $password = Get-Content "$PSScriptRoot\$Certname.pwd.txt"
        Write-Host "  thumb: $thumbprint, pass: $password"

    } else {
        $thumbprint, $password, $localPath = CreateSelfSignedCertificate $CertName
    }

    #import into vault if needed
    Write-Host "Checking certificate in key vault..."
    $kvCert = Get-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $CertName
    if($null -eq $kvCert) {
        Write-Host "  importing..."
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $kvCert = Import-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $CertName -FilePath $localPath -Password $securePassword
    } else {
        Write-Host "  certificate already imported."
    }

    $kvCert
}


Write-Host "[3] Creating self-signed certificates..."
$Cert = EnsureSelfSignedCertificate $Name $ClusterCertDnsName
Write-Host

# cluster location is taken from resource group

Write-Host "[4] Deploying cluster..."
$omsSolutionName = "$Name-sln"
$omsWorkspaceName = "$Name-wksp"

$parameters = @{
  namePart = $Name;
  certificateThumbprint = $Cert.Thumbprint;
  sourceVaultResourceId = $keyVault.ResourceId;
  certificateUrlValue = $Cert.SecretId;
}

if(-not $MiniCluster) {
   $parameters.omsSolutionName = $omsSolutionName;
   $parameters.omsWorkspaceName = $omsWorkspaceName;
   $parameters.omsEnabled = $DeployOMS.IsPresent;
}

$templateName = "prod"
if($MiniCluster) {
   $templateName = "mini"
}

Write-Host "    using template '$templateName'"

New-AzResourceGroupDeployment `
  -ResourceGroupName $Name `
  -TemplateFile "$PSScriptRoot\$templateName.json" `
  -Mode Incremental `
  -TemplateParameterObject $parameters `
  -Verbose

Write-Host

Write-Host ".all done." -ForegroundColor Green