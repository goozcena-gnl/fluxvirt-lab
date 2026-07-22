# Windows 11 Home host preparation

This runbook preserves two Windows operating modes:

- **Normal boot:** daily use, WSL2, Memory Integrity/VBS, and the normal Windows security configuration.
- **FluxVirt Lab boot:** Microsoft hypervisor and Virtual Secure Mode launch disabled for that boot entry so VirtualBox can request VT-x/AMD-V directly.

## Important interpretation rule

When `HypervisorPresent=True`, Windows already has a hypervisor using the CPU virtualization extensions. In that state, these `Win32_Processor` fields can be hidden or reported as `False`:

- `VMMonitorModeExtensions`
- `SecondLevelAddressTranslationExtensions`
- `VirtualizationFirmwareEnabled`

Do **not** interpret those three `False` values as proof that the CPU lacks virtualization or that BIOS/UEFI virtualization is disabled. The repository preflight defers those checks until the dedicated lab boot reports `HypervisorPresent=False`.

For this project, the decisive sequence is:

1. normal boot may return exit code `2` because the Microsoft hypervisor is active;
2. create a separate lab boot entry;
3. boot the lab entry;
4. rerun the preflight;
5. only then treat the CPU/firmware fields as hardware gates.

## Safety warning

Changing Boot Configuration Data can affect startup. Before making a change:

1. Create a Windows restore point or current system backup.
2. Confirm that any Windows Device Encryption or BitLocker recovery key is available.
3. Record the output of `bcdedit /enum`.
4. Keep the normal Windows boot entry intact.
5. Do not disable Secure Boot.

The lab entry reduces security for that boot session because VBS-backed protections such as Memory Integrity cannot run. Use it only for the lab, avoid untrusted workloads and general browsing, then reboot into the normal entry.

## 1. Run the initial inventory

Open PowerShell as Administrator from the repository root:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\preflight\check-host-virtualization.ps1
$LASTEXITCODE
```

Expected outcomes:

- `0`: already in a native VirtualBox-compatible boot; continue to VirtualBox installation.
- `1`: a hardware/firmware check failed while no Microsoft hypervisor was active; investigate BIOS/UEFI.
- `2`: Microsoft hypervisor/VBS is active; create and boot the dedicated lab entry.

An exit code `2` is expected on a normal Windows installation using WSL2, Virtual Machine Platform, Windows Hypervisor Platform, Memory Integrity, Credential Guard, or another VBS-backed feature.

## 2. Inspect the current state

```powershell
Get-ComputerInfo |
  Select-Object WindowsProductName, WindowsEditionId, OsArchitecture

Get-CimInstance Win32_ComputerSystem |
  Select-Object HypervisorPresent

Get-CimInstance `
  -Namespace root\Microsoft\Windows\DeviceGuard `
  -ClassName Win32_DeviceGuard |
  Select-Object VirtualizationBasedSecurityStatus,
                SecurityServicesConfigured,
                SecurityServicesRunning

bcdedit /enum '{current}'
```

`HypervisorPresent=True` means the current boot session is unsuitable for the native nested-KVM target. It does not by itself indicate a BIOS problem.

## 3. Create a dedicated lab boot entry

First list and save the existing configuration:

```powershell
bcdedit /enum
bcdedit /export "$env:USERPROFILE\Desktop\fluxvirt-bcd-backup"
```

Create a copy of the current Windows entry:

```powershell
$result = bcdedit /copy '{current}' /d 'Windows 11 Home - FluxVirt Lab'
$result
```

Extract the new identifier from the localized command output:

```powershell
$LabBootId = [regex]::Match(($result -join "`n"), '\{[0-9a-fA-F-]{36}\}').Value
if (-not $LabBootId) {
    throw 'The new boot-entry identifier could not be extracted. Stop and inspect bcdedit /enum manually.'
}
$LabBootId
$LabBootId | Set-Content "$env:USERPROFILE\Desktop\fluxvirt-lab-boot-id.txt"
```

Disable Microsoft hypervisor and Virtual Secure Mode launch **only for the copied entry**:

```powershell
bcdedit /set $LabBootId hypervisorlaunchtype off
bcdedit /set $LabBootId vsmlaunchtype off
bcdedit /timeout 10
bcdedit /enum $LabBootId
```

The normal Windows entry remains unchanged and continues to support WSL2 and VBS-backed protections.

## 4. Boot and validate the lab entry

Restart Windows and select:

```text
Windows 11 Home - FluxVirt Lab
```

From an elevated PowerShell terminal in the repository:

```powershell
Get-CimInstance Win32_ComputerSystem |
  Select-Object HypervisorPresent

.\scripts\preflight\check-host-virtualization.ps1
$LASTEXITCODE
```

Required result:

```text
HypervisorPresent : False
[PASS] VM monitor-mode extensions are reported.
[PASS] Second Level Address Translation is reported.
[PASS] Firmware virtualization is enabled.
[PASS] Host hardware preflight PASSED for native VirtualBox mode.
```

Only after this result should VirtualBox be installed and the outer Ubuntu VM created.

## 5. If the lab boot still reports `HypervisorPresent=True`

Stop before creating the VM. Confirm that the copied entry was selected and inspect it:

```powershell
$LabBootId = Get-Content "$env:USERPROFILE\Desktop\fluxvirt-lab-boot-id.txt"
bcdedit /enum $LabBootId
```

It must contain:

```text
hypervisorlaunchtype    Off
vsmlaunchtype            Off
```

Do not globally uninstall WSL2 or disable optional features yet. First verify the selected boot entry and rerun the preflight. Because the host is an Insider Preview build, record the exact build number if behavior differs:

```powershell
Get-ComputerInfo |
  Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, OsHardwareAbstractionLayer
```

## 6. If hardware fields fail after `HypervisorPresent=False`

Only in this native boot are the fields treated as real gates. Check BIOS/UEFI for settings commonly named:

- Intel Virtualization Technology;
- Intel VT-x;
- VMX;
- SVM Mode on AMD systems.

Save, reboot into the lab entry, and rerun the script. Intel VT-d/IOMMU is useful for future experiments but is not required for this MVP.

## 7. Install VirtualBox after the preflight passes

Install the Oracle VirtualBox 7.2.14 **Platform Package**. The proprietary Extension Pack is not required.

Open a new elevated PowerShell window and verify:

```powershell
VBoxManage --version
```

Then continue with `docs/INSTALLATION.md`.

## 8. Return to normal Windows operation

On this validated workstation, `VirtualMachinePlatform`, `HypervisorPlatform`, and Memory Integrity were disabled globally to obtain `HypervisorPresent=False`. Merely selecting the normal BCD entry does not automatically restore those global settings.

Before expecting WSL2 or VBS-backed protections to work again, restore the desired Windows optional features and Memory Integrity, then restart into the normal Windows entry. Re-run the host preflight before returning to the VirtualBox lab because restoring them will make `HypervisorPresent=True` again.

## 9. Remove the lab boot entry

Only after confirming its identifier:

```powershell
$LabBootId = Get-Content "$env:USERPROFILE\Desktop\fluxvirt-lab-boot-id.txt"
bcdedit /enum $LabBootId
bcdedit /delete $LabBootId
Remove-Item "$env:USERPROFILE\Desktop\fluxvirt-lab-boot-id.txt" -ErrorAction SilentlyContinue
```

Never delete `{current}`, `{default}`, or an identifier that has not been verified.

## Official references

- Microsoft: Hyper-V hardware requirement fields are not displayed when a hypervisor is detected.
- Microsoft: third-party virtualization applications conflict with Hyper-V, Memory Integrity, and Credential Guard.
- Microsoft BCDEdit `/set`: `hypervisorlaunchtype` and `vsmlaunchtype` accept `Off` or `Auto`.
- Microsoft: Memory Integrity is a VBS/HVCI feature.
- Oracle VirtualBox 7.2: nested VT-x/AMD-V and `--nested-hw-virt`.

Microsoft warns that incorrect BCDEdit changes can prevent Windows from booting. Keep the normal entry intact and verify every identifier before modification or deletion.
