# Check if the Azure PowerShell module is installed
if (-not (Get-Module -Name Az.Network -ListAvailable)) {
    Write-Host "Azure PowerShell module not found. Installing the required modules..."
    Install-Module -Name Az.Accounts, Az.Network, Az.Compute -AllowClobber -Force -Scope CurrentUser
}

# Prompt the user to select the target Azure subscription
$subscriptionId = Read-Host -Prompt "Enter the Azure subscription ID:"
Set-AzContext -SubscriptionId $subscriptionId

# Prompt the user for the resource group name
$resourceGroupName = Read-Host -Prompt "Enter the resource group name:"

# Prompt the user for the virtual network name
$vnetName = Read-Host -Prompt "Enter the virtual network name:"

# Prompt the user for the subnet name
$subnetName = Read-Host -Prompt "Enter the subnet name for the AD environment:"

# Prompt the user for the AD VM names
$dcName = Read-Host -Prompt "Enter the name for the AD Domain Controller (DC) VM:"
$serverName = Read-Host -Prompt "Enter the name for the Windows Server VM:"
$clientName = Read-Host -Prompt "Enter the name for the Windows 10 Client VM:"

# Prompt the user for the AD domain name
$domainName = Read-Host -Prompt "Enter the AD domain name:"

# Prompt the user for the AD domain admin password
$adminPassword = Read-Host -Prompt "Enter the password for the AD domain administrator account:" -AsSecureString

# Create a new Azure virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName -AddressPrefix "10.0.0.0/16"

# Create a subnet within the virtual network for the AD environment
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet

# Set the DNS server IP address to the DC VM's private IP address
$subnet.DnsServers = "10.0.0.4"

# Update the virtual network with the new subnet configuration
$vnet | Set-AzVirtualNetwork

# Create the AD Domain Controller VM
$dcConfig = New-AzVMConfig -VMName $dcName -VMSize "Standard_DS2_v2" -AvailabilitySetId ""
$dcConfig = Set-AzVMOperatingSystem -VM $dcConfig -Windows -ComputerName $dcName -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate
$dcConfig = Set-AzVMSourceImage -VM $dcConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "latest"
$dcConfig = Add-AzVMNetworkInterface -VM $dcConfig -Id $subnet.Id -Primary
$dcConfig = Set-AzVMOSDisk -VM $dcConfig -Name "$dcName-osdisk" -CreateOption FromImage -Caching ReadOnly -ManagedDiskType PremiumLRS
$dc = New-AzVM -ResourceGroupName $resourceGroupName -Location (Get-AzResourceGroup -Name $resourceGroupName).Location -VM $dcConfig

# Create the Windows Server VM
$serverConfig = New-AzVMConfig -VMName $serverName -VMSize "Standard_DS2_v2" -AvailabilitySetId ""
$serverConfig = Set-AzVMOperatingSystem -VM $serverConfig -Windows -ComputerName $serverName -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate
$serverConfig = Set-AzVMSourceImage -VM $serverConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$serverConfig = Add-AzVMNetworkInterface -VM $serverConfig -Id $subnet.Id -Primary
$serverConfig = Set-AzVMOSDisk -VM $serverConfig -Name "$serverName-osdisk" -CreateOption FromImage -Caching ReadOnly -ManagedDiskType PremiumLRS
$server = New-AzVM -ResourceGroupName $resourceGroupName -Location (Get-AzResourceGroup -Name $resourceGroupName).Location -VM $serverConfig

# Create the Windows 10 Client VM
$clientConfig = New-AzVMConfig -VMName $clientName -VMSize "Standard_DS2_v2" -AvailabilitySetId ""
$clientConfig = Set-AzVMOperatingSystem -VM $clientConfig -Windows -ComputerName $clientName -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate
$clientConfig = Set-AzVMSourceImage -VM $clientConfig -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Skus "20h2-pro" -Version "latest"
$clientConfig = Add-AzVMNetworkInterface -VM $clientConfig -Id $subnet.Id -Primary
$clientConfig = Set-AzVMOSDisk -VM $clientConfig -Name "$clientName-osdisk" -CreateOption FromImage -Caching ReadOnly -ManagedDiskType PremiumLRS
$client = New-AzVM -ResourceGroupName $resourceGroupName -Location (Get-AzResourceGroup -Name $resourceGroupName).Location -VM $clientConfig

# Output the VM details
Write-Host "Active Directory environment created successfully."
Write-Host "Domain Controller (DC) VM: $($dc.Name)"
Write-Host "Windows Server VM: $($server.Name)"
Write-Host "Windows 10 Client VM: $($client.Name)"
