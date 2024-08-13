param(
    [string]$ResourceGroupName
)

# Check if the ResourceGroupName parameter is provided
if (-not $ResourceGroupName) {
    Write-Host "Please provide a Resource Group name using the -ResourceGroupName parameter."
    exit
}

# Authenticate to Azure
Connect-AzAccount

# Get all virtual machines in the specified resource group
$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

# Start each virtual machine
foreach ($vm in $vms) {
    $vmName = $vm.Name
    Write-Host "Starting VM: $vmName"
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName
}

