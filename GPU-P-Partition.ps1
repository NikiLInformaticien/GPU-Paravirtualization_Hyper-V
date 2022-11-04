###### Test if the script is executed as administratorif (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`[Security.Principal.WindowsBuiltInRole] "Administrator")) {

Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
Break

}
else {

Write-Host "Code is running as administrator — go on executing the script..." -ForegroundColor Green

}

Write-Host "Rules :
This script is writed for nvidia cards.
Your guest and host must have same version of windows. Ex: Win Pro 21H2
Enhansed session and chekpoints in Hyper-v must be disabled.

" -ForegroundColor Yellow

Write-Host "Did you already created a virtual machine for a GPU passthrough ?"

$answer = Read-Host "y/n"

Switch ($answer){

    y {Break}
    n {throw "Please create a target virtual machine before running this script."}

}

Write-Host "This is a list of your virtual machines. Choose your target." -ForegroundColor Yellow
Get-VM | select Name


$VmName = Read-Host "Write the VM name."

$GPU = Get-VMPartitionableGpu | Where-Object Name -Match "10DE"
try {$GPU -eq $null}
catch {"You don't have a GPU capable of being paravirtualised."}

# Creation of paravirtualisation link.

Add-VMGpuPartitionAdapter -VMName $VmName 
Set-VMGpuPartitionAdapter -VMName $VmName `-MinPartitionVRAM $GPU.MinPartitionVRAM `-MaxPartitionVRAM $GPU.MaxPartitionVRAM `-OptimalPartitionVRAM $GPU.OptimalPartitionVRAM `-MinPartitionEncode $GPU.MinPartitionEncode `-MaxPartitionEncode $GPU.MaxPartitionEncode `-OptimalPartitionEncode $GPU.OptimalPartitionEncode `-MinPartitionDecode $GPU.MinPartitionDecode `-MaxPartitionDecode $GPU.MaxPartitionDecode `-OptimalPartitionDecode $GPU.OptimalPartitionDecode `-MinPartitionCompute $GPU.MinPartitionCompute `-MaxPartitionCompute $GPU.MaxPartitionCompute `-OptimalPartitionCompute $GPU.OptimalPartitionCompute

Set-VM -GuestControlledCacheTypes $true -VMName $VmName
Set-VM -LowMemoryMappedIoSpace 1Gb -VMName $VmName
Set-VM –HighMemoryMappedIoSpace 32GB –VMName $VmName

# Copy the driver of the nvidia GPU

Write-Host "Before launching the virtual machine.
Copy the driver from your host 
(all folders from C:\\Windows\System32\DriverStore\FileRepository\nv* & all filles from C:\\Windows\System32\nv*)
to your guest drive at C:\\"
