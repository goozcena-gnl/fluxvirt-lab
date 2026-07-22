# Phase 0 evidence — normal Windows boot

Date: 2026-07-22
Status: **Expected blocker identified; accelerated host preflight not yet passed**

## Observed environment

- Windows edition: Windows 11 Home (`Core`), Insider Preview
- CPU: Intel Core i7-14700KF
- Logical processors: 28
- Microsoft hypervisor present: `True`
- Virtual Machine Platform: enabled
- Windows Subsystem for Linux: enabled
- Windows Hypervisor Platform: enabled
- VBS status: running
- Memory Integrity: configured
- VirtualBox CLI: not yet installed or not present in `PATH`
- Current boot setting: `hypervisorlaunchtype Auto`

## Correct interpretation

The current normal boot is intentionally unsuitable for native VirtualBox nested acceleration because the Microsoft hypervisor and VBS-backed services are active.

The `Win32_Processor` virtualization capability fields returned `False` in this boot. Those results are not accepted as evidence of a CPU or BIOS failure while `HypervisorPresent=True`; the fields must be retested from the dedicated lab boot where the Microsoft hypervisor is not launched.

## Decision

- Keep the normal Windows boot for WSL2 and VBS-backed protections.
- Create a copied `Windows 11 Home - FluxVirt Lab` boot entry.
- Set `hypervisorlaunchtype off` and `vsmlaunchtype off` only on that copied entry.
- Reboot into the lab entry and rerun the corrected host preflight.
- Do not install K3s or claim nested KVM until Ubuntu exposes a usable `/dev/kvm`.
