# Set variables for virtual machine configurations
$adj = @("Crimson", "Golden", "Electric", "Azure", "Turquoise")
$noun = @("Phoenix", "Lion", "Eagle", "Dragon", "Tiger")
$vmConfigs = @()
$vmConfigs += New-AzVMConfig -VMSize "Standard_DS1_v2"
$vmConfigs += New-AzVMConfig -VMSize "Standard_DS1_v2"
$vmConfigs += New-AzVMConfig -VMSize "Standard_DS1_v2"
$vmConfigs[0] = $vmConfigs[0] | Set-AzVMOperatingSystem -Windows -Credential (Get-Credential) -ComputerName "VM01"
$vmConfigs[1] = $vmConfigs[1] | Set-AzVMOperatingSystem -Windows -Credential (Get-Credential) -ComputerName "VM02"
$vmConfigs[2] = $vmConfigs[2] | Set-AzVMOperatingSystem -Linux -Credential (Get-Credential) -ComputerName "VM03"

# Create virtual machines in each resource group
foreach ($rgName in @("Space", "Sky", "Aqua", "Terra")) {
    $rg = Get-AzResourceGroup -Name $rgName
    $location = $rg.Location
    for ($i = 0; $i -lt 3; $i++) {
        $vmConfig = New-AzVMConfig -VMSize "Standard_DS1_v2"
        $adjIndex = Get-Random -Minimum 0 -Maximum ($adj.Count - 1)
        $nounIndex = Get-Random -Minimum 0 -Maximum ($noun.Count - 1)
        $vmName = "VM-$($adj[$adjIndex])-$($noun[$nounIndex])"
        $vmConfig = $vmConfig | Set-AzVMOperatingSystem -Credential (Get-Credential) -ComputerName $vmName
        if ($vmConfigs[$i].OSProfile.WindowsConfiguration) {
            $vmConfig = $vmConfig | Set-AzVMOperatingSystem -Windows -ComputerName $("WIN-" + $vmName) | Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest
        } else {
            $vmConfig = $vmConfig | Set-AzVMOperatingSystem -Linux -ComputerName $("LIN-" + $vmName) | Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version latest
        }
        $vmConfig = $vmConfig | Set-AzVMLocation -Location $location
        New-AzVM -ResourceGroupName $rgName -VM $vmConfig
    }
}

