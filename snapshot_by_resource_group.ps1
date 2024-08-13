param (
    [string]$resourceGroupName
)

# Check if the resource group name is provided
if (-not $resourceGroupName) {
    Write-Host "Please provide the resource group name as an argument."
    exit
}

# Install Azure PowerShell Module if not already installed
# Install-Module -Name Az -AllowClobber -Force

# Connect to Azure Account
# Connect-AzAccount

# Get a list of all VMs in the specified resource group
$vms = Get-AzVM -ResourceGroupName $resourceGroupName

# Check if any VMs are found
if ($vms.Count -eq 0) {
    Write-Host "No VMs found in the specified resource group: $resourceGroupName"
    exit
}

# Loop through each VM and take a snapshot
foreach ($vm in $vms) {
    $vmName = $vm.Name
    $snapshotName = "${vmName}-Snapshot"  # You can customize the snapshot name here

    # Create VM Snapshot
    $snapshotConfig = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $vm.Location -CreateOption Copy
    $snapshot = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

    Write-Host "Snapshot created for VM: $vmName"
}

