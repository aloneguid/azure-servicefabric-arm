<#
 Ignore this file, not ready yet.
#>

param(
   [string] [Parameter(Mandatory = $true)] $Name
)

# Global constants
$ErrorActionPreference = 'Stop'
$resourceUrl = "https://graph.windows.net"
$authString = "https://login.microsoftonline.com/" + $TenantId

# load the ADAL library
Try
{
    $FilePath = Join-Path $PSScriptRoot "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    Add-Type -Path $FilePath
}
Catch
{
    Write-Warning $_.Exception.Message
}

Write-Host "[ ] Preparing the environment..."

Write-Host "    looking for tenant..."
$rmContext = Get-AzureRmContext
$tenantId = $rmContext.Tenant.Id
Write-Host "    tenant id: $tenantId ($($rmContext.Subscription.Name))"

Write-Host "    looking for Service Fabric cluster..."
$sfCluster = Get-AzureRmServiceFabricCluster | Where-Object { $_.Name -eq $Name }
$explorerEndpoint = $sfCluster.ManagementEndpoint + "/Explorer"
if($sfCluster -eq $null) {
   Write-Host "[!] cluster '$Name' does not exist."
   exit
} else {
   Write-Host "    found cluster, management endpoint: $($sfCluster.ManagementEndpoint)"
}

