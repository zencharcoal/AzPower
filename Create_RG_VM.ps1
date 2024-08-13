# Set variables for resource group names and virtual machine configurations
$adj = @("Crimson", "Golden", "Electric", "Azure", "Turquoise")
$noun = @("Phoenix", "Lion", "Eagle", "Dragon", "Tiger")
$location = "eastus"
$vmOS = Read-Host "Enter the operating system for the virtual machine (Windows/Linux)"
if ($vmOS -eq "Windows") {
    $vmConfig = New-AzVMConfig -VMName "VM-$($adj | Get-Random)-$($noun | Get-Random)" -VMSize "Standard_DS1_v2" | `
                Set-AzVMOperatingSystem -Windows -ComputerName "VM-$($adj | Get-Random)-$($noun | Get-Random)" -Credential (Get-Credential) | `
                Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest
} elseif ($vmOS -eq "Linux") {
    $vmConfig = New-AzVMConfig -VMName "VM-$($adj | Get-Random)-$($noun | Get-Random)" -VMSize "Standard_DS1_v2" | `
                Set-AzVMOperatingSystem -Linux -ComputerName "VM-$($adj | Get-Random)-$($noun | Get-Random)" -Credential (Get-Credential) | `
                Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version latest
} else {
    Write-Host "Invalid operating system specified."
    Exit
}

# Create the three resource groups
$rg1Name = "RG-$($adj | Get-Random)-$($noun | Get-Random)-01"
$rg2Name = "RG-$($adj | Get-Random)-$($noun | Get-Random)-02"
$rg3Name = "RG-$($adj | Get-Random)-$($noun | Get-Random)-03"
New-AzResourceGroup -Name $rg1Name -Location $location
New-AzResourceGroup -Name $rg2Name -Location $location
New-AzResourceGroup -Name $rg3Name -Location $location

# Create a virtual machine in each resource group
New-AzVM -ResourceGroupName $rg1Name -Location $location @vmConfig
New-AzVM -ResourceGroupName $rg2Name -Location $location @vmConfig
New-AzVM -ResourceGroupName $rg3Name -Location $location @vmConfig

