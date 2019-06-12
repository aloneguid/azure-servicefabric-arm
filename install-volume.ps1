param(
   [string] [Parameter(Mandatory = $true)] $ClusterName,
   [string] $Location = "northeurope"
)

$typeName = "AzureFilesVolumePluginType"
$path = "$PSScriptRoot\AzureFilesVolumePlugin.6.4.571.9590\Windows"
$endpoint = "$ClusterName.$Location.cloudapp.azure.com:19000"
$thumbprint = Get-Content "$PSScriptRoot\cluster$($ClusterName).thumb.txt"
$version = "6.4.571.9590"

function Unregister-ApplicationTypeCompletely([string]$ApplicationTypeName, $ApplicationTypeVersion)
{
    Write-Host "checking if application type $ApplicationTypeName is present.."
    $type = Get-ServiceFabricApplicationType -ApplicationTypeName $ApplicationTypeName -ApplicationTypeVersion $ApplicationTypeVersion
    if($null -eq $type) {
        Write-Host "  application is not in the cluster" -ForegroundColor Green
    } else {
        $runningApps = Get-ServiceFabricApplication -ApplicationTypeName $ApplicationTypeName
        foreach($app in $runningApps) {
            $uri = $app.ApplicationName.AbsoluteUri
            Write-Host "    unregistering '$uri'..."

            $t = Remove-ServiceFabricApplication -ApplicationName $uri -ForceRemove -Verbose -Force
        }

        Write-Host "  unregistering type..."
        $t =Unregister-ServiceFabricApplicationType `
            -ApplicationTypeName $ApplicationTypeName -ApplicationTypeVersion $type.ApplicationTypeVersion `
            -Force -Confirm

    }
}

Write-Host "connecting to cluster $endpoint using cert thumbprint $thumbprint..."
Connect-ServiceFabricCluster -ConnectionEndpoint $endpoint `
    -X509Credential `
    -ServerCertThumbprint $thumbprint `
    -FindType FindByThumbprint -FindValue $thumbprint `
    -StoreLocation CurrentUser -StoreName My

Unregister-ApplicationTypeCompletely $typeName

Write-Host "uploading test application binary to the cluster..."
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $path -ApplicationPackagePathInImageStore $typeName -TimeoutSec 1800 -ShowProgress

Write-Host "registering application..."
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $typeName

Write-Host "creating application..."
New-ServiceFabricApplication -ApplicationName "fabric:/$typeName" -ApplicationTypeName $typeName -ApplicationTypeVersion $version
