#Requires -Version 5.1
#Requires -RunAsAdministrator
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$hardwareFailures = 0
$accelerationBlockers = 0

function Write-Pass([string]$Message) { Write-Host "[PASS] $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Fail([string]$Message) { Write-Host "[FAIL] $Message" -ForegroundColor Red }
function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }

Write-Info 'Collecting Windows Home, CPU, firmware, Microsoft hypervisor, VBS, and VirtualBox information.'
$os = Get-CimInstance Win32_OperatingSystem
$computerSystem = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$computerInfo = Get-ComputerInfo
$hypervisorPresent = [bool]$computerSystem.HypervisorPresent

Write-Host "Windows: $($os.Caption)"
Write-Host "Edition ID: $($computerInfo.WindowsEditionId)"
Write-Host "Architecture: $($os.OSArchitecture)"
Write-Host "CPU: $($cpu.Name)"
Write-Host "Logical processors: $($cpu.NumberOfLogicalProcessors)"
Write-Host "Microsoft hypervisor present: $hypervisorPresent"

if ($os.Caption -match 'Home|Famille' -or $computerInfo.WindowsEditionId -eq 'Core') {
    Write-Pass 'Windows Home edition detected; VirtualBox is the selected hypervisor path.'
} else {
    Write-Warn 'This repository is tailored to Windows 11 Home, but another edition was detected.'
}

if ($os.OSArchitecture -match '64') {
    Write-Pass '64-bit Windows architecture is reported.'
} else {
    Write-Fail 'A 64-bit x86 Windows host is required.'
    $hardwareFailures++
}

Write-Host ''
Write-Info 'CPU virtualization capability fields:'
Write-Host "  VMMonitorModeExtensions: $($cpu.VMMonitorModeExtensions)"
Write-Host "  SecondLevelAddressTranslationExtensions: $($cpu.SecondLevelAddressTranslationExtensions)"
Write-Host "  VirtualizationFirmwareEnabled: $($cpu.VirtualizationFirmwareEnabled)"

if ($hypervisorPresent) {
    # Once the Microsoft hypervisor owns VT-x/AMD-V, Windows can hide or return
    # False for these host-requirement fields. They must not be interpreted as
    # a physical CPU or BIOS failure in this boot session.
    Write-Warn 'The Microsoft hypervisor is active, so the Win32_Processor virtualization fields above are not a reliable physical-hardware test.'
    Write-Warn 'Hardware/firmware validation is deferred until the dedicated FluxVirt Lab boot reports HypervisorPresent=False.'
} else {
    if ($cpu.VMMonitorModeExtensions) {
        Write-Pass 'VM monitor-mode extensions are reported.'
    } else {
        Write-Fail 'VM monitor-mode extensions are not reported in a native boot. Check CPU support and BIOS/UEFI.'
        $hardwareFailures++
    }

    if ($cpu.SecondLevelAddressTranslationExtensions) {
        Write-Pass 'Second Level Address Translation is reported.'
    } else {
        Write-Fail 'SLAT is not reported in a native boot. Nested virtualization compatibility is insufficient.'
        $hardwareFailures++
    }

    if ($cpu.VirtualizationFirmwareEnabled) {
        Write-Pass 'Firmware virtualization is enabled.'
    } else {
        Write-Fail 'Firmware virtualization is disabled or unavailable in a native boot. Enable Intel VT-x or AMD-V in BIOS/UEFI.'
        $hardwareFailures++
    }
}

Write-Host ''
Write-Info 'Windows virtualization-related optional features:'
$featureNames = @(
    'VirtualMachinePlatform',
    'Microsoft-Windows-Subsystem-Linux',
    'HypervisorPlatform',
    'Containers-DisposableClientVM',
    'Microsoft-Hyper-V-All'
)
foreach ($featureName in $featureNames) {
    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName -ErrorAction Stop
        Write-Host ("  {0}: {1}" -f $feature.FeatureName, $feature.State)
    } catch {
        Write-Host ("  {0}: not available on this edition" -f $featureName)
    }
}

try {
    $deviceGuard = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName Win32_DeviceGuard
    Write-Host "VBS status code: $($deviceGuard.VirtualizationBasedSecurityStatus)"
    Write-Host "Security services configured: $($deviceGuard.SecurityServicesConfigured -join ',')"
    Write-Host "Security services running: $($deviceGuard.SecurityServicesRunning -join ',')"
    if ($deviceGuard.VirtualizationBasedSecurityStatus -gt 0) {
        Write-Warn 'VBS is configured or active in this boot session.'
    }
} catch {
    Write-Warn "Could not query Device Guard/VBS: $($_.Exception.Message)"
}

$memoryIntegrityPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'
if (Test-Path $memoryIntegrityPath) {
    $memoryIntegrity = (Get-ItemProperty -Path $memoryIntegrityPath -Name Enabled -ErrorAction SilentlyContinue).Enabled
    Write-Host "Memory Integrity configured value: $memoryIntegrity"
    if ($memoryIntegrity -eq 1) {
        Write-Warn 'Memory Integrity is configured. It should remain available in the normal boot, but it will not run in the dedicated lab boot where VSM/hypervisor launch is disabled.'
    }
}

if ($hypervisorPresent) {
    Write-Fail 'The Microsoft hypervisor is active. Native VirtualBox nested acceleration is blocked for this session.'
    Write-Warn 'Create and boot the dedicated FluxVirt Lab entry described in docs/WINDOWS-HOME.md. WSL2 and VBS-backed protections will not run in that lab boot.'
    $accelerationBlockers++
} else {
    Write-Pass 'No Microsoft hypervisor is reported in the current boot session.'
}

$vbox = Get-Command VBoxManage.exe -ErrorAction SilentlyContinue
if ($vbox) {
    $vboxVersion = & $vbox.Source --version
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "VBoxManage found: $vboxVersion"
    } else {
        Write-Warn 'VBoxManage was found but its version command failed.'
    }
} else {
    Write-Warn 'VBoxManage is not installed or not in PATH. Install the VirtualBox 7.2 Platform Package only after the native-boot hardware preflight passes.'
}

Write-Host ''
Write-Info 'Boot configuration summary:'
try {
    bcdedit.exe /enum '{current}' |
        Select-String -Pattern 'identifier|identificateur|description|hypervisorlaunchtype|vsmlaunchtype|type de lancement'
} catch {
    Write-Warn "Could not query BCD: $($_.Exception.Message)"
}

if ($hardwareFailures -gt 0) {
    Write-Fail "$hardwareFailures physical hardware or firmware requirement(s) failed in a native boot. Do not create the lab VM."
    exit 1
}

if ($accelerationBlockers -gt 0) {
    Write-Fail 'Current boot is not suitable for native VirtualBox nested acceleration. Hardware fields were deferred, not failed.'
    exit 2
}

Write-Pass 'Host hardware preflight PASSED for native VirtualBox mode.'
Write-Info 'Next: install VirtualBox 7.2 Platform Package, create the VM, and validate /dev/kvm inside Ubuntu.'
exit 0
