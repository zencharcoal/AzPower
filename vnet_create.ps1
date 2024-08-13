# Prompt the user to select the target Azure subscription
$subscriptionId = Read-Host -Prompt "Enter the Azure subscription ID:"
Set-AzContext -SubscriptionId $subscriptionId

# Prompt the user for VNET details
$vnetName = Read-Host -Prompt "Enter the VNET name:"
$addressSpace = Read-Host -Prompt "Enter the address space (CIDR format, e.g., 10.0.0.0/16):"
$resourceGroupName = Read-Host -Prompt "Enter the target resource group name:"

# Prompt the user to select the Azure region/location
Write-Host "Select the Azure region/location for the VNET:"
$locations = Get-AzLocation | Select-Object -Property DisplayName
for ($i = 0; $i -lt $locations.Length; $i++) {
    Write-Host ("{0}. {1}" -f ($i + 1), $locations[$i].DisplayName)
}

$regionIndex = Read-Host -Prompt "Enter the number corresponding to the desired Azure region:"
$location = $locations[$regionIndex - 1].DisplayName

# Create the VNET
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $addressSpace
