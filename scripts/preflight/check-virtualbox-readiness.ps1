#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$VMName = 'fluxvirt-lab'
)

$ErrorActionPreference = 'Stop'
$failures = 0

function Write-Pass([string]$Message) { Write-Host "[PASS] $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Fail([string]$Message) { Write-Host "[FAIL] $Message" -ForegroundColor Red; $script:failures++ }

$computerSystem = Get-CimInstance Win32_ComputerSystem
if ($computerSystem.HypervisorPresent) {
    Write-Fail 'The Microsoft hypervisor is active. Reboot into the dedicated FluxVirt Lab boot entry.'
} else {
    Write-Pass 'No Microsoft hypervisor is reported.'
}

$vbox = Get-Command VBoxManage.exe -ErrorAction SilentlyContinue
if (-not $vbox) {
    Write-Fail 'VBoxManage.exe was not found in PATH.'
} else {
    $version = & $vbox.Source --version
    if ($LASTEXITCODE -eq 0) { Write-Pass "VirtualBox found: $version" }
    else { Write-Fail 'VirtualBox version query failed.' }
}

if ($vbox) {
    $vmList = & $vbox.Source list vms
    if ($LASTEXITCODE -ne 0 -or -not ($vmList | Select-String -SimpleMatch ('"' + $VMName + '"'))) {
        Write-Fail "VirtualBox VM '$VMName' was not found."
    } else {
        Write-Pass "VirtualBox VM '$VMName' exists."
        $info = & $vbox.Source showvminfo $VMName --machinereadable
        if ($LASTEXITCODE -ne 0) {
            Write-Fail 'Could not read VM configuration.'
        } else {
            $nested = $info | Select-String -Pattern '^(nested-hw-virt|NestedHWVirt)=' -CaseSensitive:$false
            if ($nested -and $nested.Line -match 'on|true|1') {
                Write-Pass 'Nested hardware virtualization is enabled in the VM configuration.'
            } else {
                Write-Fail 'Nested hardware virtualization is not confirmed in the VM configuration.'
            }

            $memory = $info | Select-String -Pattern '^memory='
            $cpus = $info | Select-String -Pattern '^cpus='
            $state = $info | Select-String -Pattern '^VMState='
            if ($memory) { Write-Host $memory.Line }
            if ($cpus) { Write-Host $cpus.Line }
            if ($state) { Write-Host $state.Line }
        }
    }
}

if ($failures -gt 0) {
    Write-Fail "$failures VirtualBox readiness check(s) failed."
    exit 1
}

Write-Pass 'VirtualBox configuration preflight PASSED. Ubuntu /dev/kvm validation is still mandatory.'
exit 0
