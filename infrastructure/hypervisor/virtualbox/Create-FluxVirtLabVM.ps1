#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$VMName = 'fluxvirt-lab',
    [Parameter(Mandatory = $true)][ValidateScript({ Test-Path $_ })][string]$IsoPath,
    [string]$VMRoot = "$env:USERPROFILE\VirtualBox VMs",
    [ValidateRange(2, 32)][int]$ProcessorCount = 8,
    [ValidateRange(8192, 65536)][int]$MemoryMB = 16384,
    [ValidateRange(81920, 1048576)][int]$DiskMB = 153600,
    [switch]$AllowDegradedMicrosoftHypervisorBackend
)

$ErrorActionPreference = 'Stop'

function Invoke-VBox {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
    & $script:VBoxManage @Arguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "VBoxManage failed with exit code ${exitCode}: $($Arguments -join ' ')"
    }
}

$vbox = Get-Command VBoxManage.exe -ErrorAction SilentlyContinue
if (-not $vbox) {
    throw 'VBoxManage.exe was not found in PATH. Install the VirtualBox 7.2 Platform Package first.'
}
$script:VBoxManage = $vbox.Source

$computerSystem = Get-CimInstance Win32_ComputerSystem
if ($computerSystem.HypervisorPresent -and -not $AllowDegradedMicrosoftHypervisorBackend) {
    throw @'
The Microsoft hypervisor is active. Native VirtualBox nested acceleration is not available in this session.
Boot the dedicated FluxVirt Lab entry from docs/WINDOWS-HOME.md and rerun the host preflight.
Use -AllowDegradedMicrosoftHypervisorBackend only for an explicitly degraded experiment; /dev/kvm may be unavailable.
'@
}
if ($computerSystem.HypervisorPresent) {
    Write-Warning 'DEGRADED HOST MODE: the Microsoft hypervisor is active. Do not claim nested KVM success without /dev/kvm proof.'
}

$version = & $script:VBoxManage --version
if ($LASTEXITCODE -ne 0) { throw 'Unable to query the VirtualBox version.' }
Write-Host "VirtualBox version: $version"

$os = Get-CimInstance Win32_OperatingSystem
$availableMemoryMB = [math]::Floor($os.FreePhysicalMemory / 1024)
$recommendedHostReserveMB = 4096
Write-Host "Available host memory before VM creation: $availableMemoryMB MiB"
if ($availableMemoryMB -lt ($MemoryMB + $recommendedHostReserveMB)) {
    Write-Warning "Requested VM memory is $MemoryMB MiB, but only $availableMemoryMB MiB is currently free. Close applications or rerun with -MemoryMB 12288 to preserve at least 4 GiB for Windows."
}

$existing = & $script:VBoxManage list vms | Select-String -SimpleMatch ('"' + $VMName + '"')
if ($existing) { throw "VirtualBox VM '$VMName' already exists. Refusing to overwrite it." }

$resolvedIso = (Resolve-Path $IsoPath).Path
$created = $false
try {
    Invoke-VBox createvm --name $VMName --ostype Ubuntu_64 --basefolder $VMRoot --register
    $created = $true

    Invoke-VBox modifyvm $VMName `
        --cpus $ProcessorCount `
        --memory $MemoryMB `
        --vram 16 `
        --firmware efi `
        --nested-hw-virt on `
        --ioapic on `
        --pae on `
        --rtc-use-utc on `
        --graphicscontroller vmsvga `
        --boot1 dvd `
        --boot2 disk `
        --boot3 none `
        --boot4 none

    Invoke-VBox modifyvm $VMName --nic1 nat --nictype1 virtio --natdnshostresolver1 on
    Invoke-VBox modifyvm $VMName --natpf1 'ubuntu-ssh,tcp,127.0.0.1,2222,,22'
    Invoke-VBox modifyvm $VMName --natpf1 'kubernetes-api,tcp,127.0.0.1,6443,,6443'
    Invoke-VBox modifyvm $VMName --natpf1 'vm-ssh,tcp,127.0.0.1,30022,,30022'
    Invoke-VBox modifyvm $VMName --natpf1 'vm-http,tcp,127.0.0.1,30080,,30080'
    Invoke-VBox modifyvm $VMName --natpf1 'container-http,tcp,127.0.0.1,30081,,30081'

    $vmDir = Join-Path $VMRoot $VMName
    $disk = Join-Path $vmDir "$VMName.vdi"
    Invoke-VBox createmedium disk --filename $disk --size $DiskMB --format VDI --variant Standard
    Invoke-VBox storagectl $VMName --name SATA --add sata --controller IntelAhci
    Invoke-VBox storageattach $VMName --storagectl SATA --port 0 --device 0 --type hdd --medium $disk
    Invoke-VBox storagectl $VMName --name IDE --add ide
    Invoke-VBox storageattach $VMName --storagectl IDE --port 0 --device 0 --type dvddrive --medium $resolvedIso

    Write-Host "Created VirtualBox VM '$VMName'." -ForegroundColor Green
    Write-Host "  CPUs: $ProcessorCount"
    Write-Host "  Memory: $MemoryMB MiB"
    Write-Host "  Disk: $DiskMB MiB dynamic VDI"
    Write-Host '  Nested VT-x/AMD-V requested: on'
    Write-Host '  Network: NAT with localhost port forwards'
    Write-Host ''
    Write-Host ".\scripts\preflight\check-virtualbox-readiness.ps1 -VMName '$VMName'"
    Write-Host "VBoxManage startvm '$VMName' --type gui"
    Write-Host 'After Ubuntu installation, nested virtualization is accepted only when /dev/kvm passes the guest preflight.'
} catch {
    Write-Error $_
    if ($created) {
        Write-Warning "A partial VM may exist. Inspect it before cleanup: VBoxManage showvminfo '$VMName'"
        Write-Warning "Deliberate cleanup command: VBoxManage unregistervm '$VMName' --delete"
    }
    exit 1
}
