# Check if the Azure PowerShell module is installed
if (-not (Get-Module -Name Az.Network -ListAvailable)) {
    Write-Host "Azure PowerShell module not found. Installing the required modules..."
    Install-Module -Name Az.Accounts, Az.Network -AllowClobber -Force -Scope CurrentUser
}

# Prompt the user to select the target Azure subscription
$subscriptionId = Read-Host -Prompt "Enter the Azure subscription ID:"
Set-AzContext -SubscriptionId $subscriptionId

# Prompt the user for the resource group name
$resourceGroupName = Read-Host -Prompt "Enter the resource group name:"

# Prompt the user for the existing VNet name
$vnetName = Read-Host -Prompt "Enter the existing VNet name:"

# Prompt the user for the gateway name
$gatewayName = Read-Host -Prompt "Enter the gateway name:"

# Prompt the user for the gateway subnet address prefix
$gatewaySubnetPrefix = Read-Host -Prompt "Enter the gateway subnet address prefix (CIDR format, e.g., 172.31.0.0/28):"

# Prompt the user for the name of the new public IP
$publicIpName = Read-Host -Prompt "Enter the name for the new public IP:"

# Prompt the user to select the Azure region/location for the gateway
Write-Host "Select the Azure region/location for the gateway:"
$locations = Get-AzLocation | Select-Object -Property DisplayName
for ($i = 0; $i -lt $locations.Length; $i++) {
    Write-Host ("{0}. {1}" -f ($i + 1), $locations[$i].DisplayName)
}

$regionIndex = Read-Host -Prompt "Enter the number corresponding to the desired Azure region:"
$location = $locations[$regionIndex - 1].DisplayName

# Retrieve the existing VNet
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName

# Check if the GatewaySubnet already exists
$existingGatewaySubnet = $vnet.Subnets | Where-Object { $_.Name -eq "GatewaySubnet" }
if ($existingGatewaySubnet) {
    Write-Host "The GatewaySubnet already exists in the VNet."
}
else {
    # Add the GatewaySubnet to the existing VNet
    $vnet | Add-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix $gatewaySubnetPrefix
    Set-AzVirtualNetwork -VirtualNetwork $vnet
}

# Create a new public IP address with static allocation method
$publicIp = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static -Sku Standard

# Create the IP configuration for the gateway and associate the public IP address
$gatewayIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name "GatewayIpConfig" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id

# Create the virtual network gateway
New-AzVirtualNetworkGateway -Name $gatewayName -ResourceGroupName $resourceGroupName -Location $location -IpConfigurations @($gatewayIpConfig) -GatewayType Vpn -VpnType RouteBased

Write-Host "Virtual network gateway created successfully."
