# Usage .\Change_PublicIinsert_token_herep.ps1 -resourceGroupName "YourResourceGroupName" -publicIpName "OldPublicIpName" -newPublicIpName "NewPublicIpName" -location "YourLocation" -nicName "YourNicName" -sku Standard

 param (
    [string]$resourceGroupName = "YourResourceGroup",  # Replace with your resource group name
    [string]$oldPublicIpName = "OldPublicIpName",     # Replace with the name of the old public IP address
    [string]$newPublicIpName = "NewPublicIpName",     # Replace with the name of the new public IP address
    [string]$sku = "Standard"                         # Replace with "Standard" or "Basic" as desired
)

# Connect to Azure (You can skip this if you're already authenticated)
Connect-AzAccount

# Check if the old public IP address exists
$oldPublicIp = Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $oldPublicIpName -ErrorAction SilentlyContinue

if ($oldPublicIp) {
    # Create a new public IP address with the specified SKU and static allocation method (if it doesn't exist)
    $newPublicIp = Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $newPublicIpName -ErrorAction SilentlyContinue

    if (!$newPublicIp) {
        $newPublicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $newPublicIpName -AllocationMethod Static -Sku $sku -Location "YourLocation"  # Replace with your location
    }

    # Check if the new public IP address has a static allocation method
    if ($newPublicIp.AllocationMethod -ne "Static") {
        # Update the allocation method to static
        $newPublicIp | Set-AzPublicIpAddress -AllocationMethod Static
    }

    # Remove the association of the old public IP address (if associated with any resource)
    $oldPublicIpConfig = $oldPublicIp | Get-AzResource -ExpandProperty Properties | Select-Object -ExpandProperty IpConfiguration
    if ($oldPublicIpConfig) {
        $oldPublicIpConfig | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $null -Name $oldPublicIpName -ResourceGroupName $resourceGroupName -Force
    }

    # Delete the old public IP address
    Remove-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $oldPublicIpName -Force

    Write-Host "Old public IP address '$oldPublicIpName' has been replaced with '$newPublicIpName' (SKU: $sku)."
} else {
    Write-Host "Old public IP address '$oldPublicIpName' not found in resource group '$resourceGroupName'. No changes were made."
}


