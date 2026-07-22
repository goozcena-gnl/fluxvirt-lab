# Phase 0 evidence — native VirtualBox-compatible boot

Validation date: 2026-07-22
Status: **PASS**

## Target workstation evidence

```text
Windows: Microsoft Windows 11 Famille Insider Preview
Edition ID: Core
Architecture: 64 bits
CPU: Intel(R) Core(TM) i7-14700KF
Logical processors: 28
Microsoft hypervisor present: False
VMMonitorModeExtensions: True
SecondLevelAddressTranslationExtensions: True
VirtualizationFirmwareEnabled: True
VirtualMachinePlatform: Disabled
Microsoft-Windows-Subsystem-Linux: Enabled
HypervisorPlatform: Disabled
VBS status code: 0
Security services configured: 0
Security services running: 0
Memory Integrity configured value: 0
Boot description: Windows 11 Home - FluxVirt Lab
vsmlaunchtype: Off
```

The repository preflight reported:

```text
[PASS] Host hardware preflight PASSED for native VirtualBox mode.
```

PowerShell exit code:

```text
0
```

## Verified conclusions

- CPU hardware virtualization is visible to Windows.
- Intel EPT/SLAT is visible.
- Firmware virtualization is enabled.
- The Microsoft hypervisor is not active in this boot.
- VBS/HVCI is inactive.
- The host is ready for native VirtualBox installation and outer-VM creation.

## Still unverified

- VirtualBox installation and driver health.
- `nested-hw-virt=on` in the created VM.
- VT-x visibility inside Ubuntu.
- `/dev/kvm` existence and usability inside Ubuntu.
- K3s, Flux, CDI, KubeVirt, VM, and application runtime health.
