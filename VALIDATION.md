# Validation report

Validation date: 2026-07-22
Target host profile: Windows 11 Home x86_64 with Oracle VirtualBox 7.2.14

## Verified in the artifact environment

- 37 YAML documents parse successfully with PyYAML.
- All local Kustomization resource paths resolve, except CDI release assets intentionally produced by `make vendor` before Flux bootstrap.
- Every Bash script passes `bash -n` syntax validation.
- No OpenSSH/RSA/EC private-key block or GitHub token pattern was found outside vendored files.
- Vendored KubeVirt v1.8.4 operator and custom-resource manifests match the release-published SHA-256 values.
- Shell scripts are executable.
- Hyper-V provisioning content has been removed from the Windows Home edition.
- The repository contains 75 files after the corrected Windows Home preflight revision.
- Documentation, preflight logic, networking, and portfolio copy now use VirtualBox as the primary path.
- The host preflight no longer treats masked `Win32_Processor` fields as physical failures while `HypervisorPresent=True`; it returns blocker exit code `2` and defers hardware checks to the native lab boot.
- A sanitized Phase 0 normal-boot evidence record is stored in `docs/evidence/phase-0-normal-boot.md`.
- PowerShell files passed delimiter/structure checks; they were not parsed or executed by Windows PowerShell in this environment.

## Verified on the target workstation

- Windows 11 Home Insider Preview (`Edition ID: Core`) detected.
- Intel Core i7-14700KF and 28 logical processors detected.
- Dedicated `Windows 11 Home - FluxVirt Lab` boot entry selected.
- `HypervisorPresent=False`.
- `VMMonitorModeExtensions=True`.
- `SecondLevelAddressTranslationExtensions=True`.
- `VirtualizationFirmwareEnabled=True`.
- `VirtualMachinePlatform=Disabled`.
- `HypervisorPlatform=Disabled`.
- VBS status is `0`; no configured or running VBS security services were reported.
- Memory Integrity configured value is `0`.
- `check-host-virtualization.ps1` completed with exit code `0`.
- Evidence is stored in `docs/evidence/phase-0-native-boot.md`.

- VirtualBox 7.2.14r174565 is installed and responds to `VBoxManage`.
- VirtualBox reports host hardware virtualization, nested paging, unrestricted guest mode, and nested hardware virtualization support.
- The first VM-creation attempt was blocked by a PowerShell parser defect before execution; the ambiguous `$LASTEXITCODE:` interpolation has been corrected.
- Phase 1 host evidence is stored in `docs/evidence/phase-1-virtualbox-host.md`.

## Not executed or not yet empirically verified

- Outer VirtualBox VM creation and configuration readiness.
- VirtualBox nested VT-x/AMD-V exposure.
- Nested virtualization and `/dev/kvm` availability.
- Ubuntu Server installation or hardening.
- K3s installation and runtime behavior.
- Flux bootstrap and reconciliation.
- CDI release-asset download and cluster deployment.
- KubeVirt operator runtime health.
- DataVolume import, VM boot, cloud-init, SSH, or HTTP reachability.
- Container workload deployment.
- GitHub Actions execution.

No runtime component is represented as successful until evidence from the target workstation is captured.
