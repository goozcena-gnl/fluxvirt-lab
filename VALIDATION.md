# Validation report

> **Historical scope:** This report records the evidence available on
> 2026-07-22. It predates the later runtime acceptance, recovery exercise,
> release pull request, and v0.1.0 publication described below.

## Current evidence reconciliation

Reconciled on 2026-08-09 from repository-retained documents and GitHub
records:

| Capability | Dated evidence | Conclusion |
|---|---|---|
| Windows host preflight | `docs/evidence/phase-0-native-boot.md`, 2026-07-22 | VERIFIED |
| VirtualBox host readiness | `docs/evidence/phase-1-virtualbox-host.md`, 2026-07-22 | VERIFIED |
| Nested KVM, K3s, Flux CD, KubeVirt, CDI, VM and container | [PR #3](https://github.com/goozcena-gnl/fluxvirt-lab/pull/3) runtime output, merged 2026-07-27; v0.1.0 Release, 2026-07-27 | DOCUMENTED BUT NOT INDEPENDENTLY RETAINED |
| VM-disk recovery | `docs/BACKUP-RESTORE.md` run marker and SHA-256; v0.1.0 Release, 2026-07-27 | DOCUMENTED BUT NOT INDEPENDENTLY RETAINED |
| Repository CI and Validation/Trivy | Latest `main` runs for commit `5a80b68`, 2026-07-28 | VERIFIED — STATIC ONLY |

[PR #3](https://github.com/goozcena-gnl/fluxvirt-lab/pull/3) retains concise acceptance output covering Flux reconciliation,
KubeVirt/CDI state, VM and container readiness, QEMU Guest Agent connectivity,
and both HTTP endpoints. The recovery guide retains a run-specific marker and
backup checksum, but says its 22 detailed artifacts remain outside the
repository. Current-facing documents therefore describe these as recorded,
bounded v0.1.0 results rather than independently reproducible raw evidence.

## 2026-09-21 hardening session (static-only)

Executed in this repository sandbox:

- `kubectl` v1.35.6 downloaded from `dl.k8s.io` and verified against the
  published `.sha256` sidecar before local installation.
- `./scripts/install/install-kubeconform.sh --install-dir "$HOME/.local/bin"`
  verified `kubeconform-linux-amd64.tar.gz` for `v0.7.0` against the
  upstream `CHECKSUMS` file before local installation.
- `./scripts/bootstrap/install-k3s.sh --verify-only` verified the vendored
  `vendor/k3s/install-v1.35.6+k3s1.sh` copy against pinned SHA-256
  `8598e002e61d658fed7b7542fc6d2c66d8da6eae69e088830105d2ee1ffb6d91`
  and upstream K3s tag commit
  `87243446a2c2fe958c31ad552fe38ebf96757b06`.
- `shellcheck $(find scripts -type f -name '*.sh' -print)` passed.
- `bash -n` passed for every `scripts/**/*.sh` file.
- `yamllint -c .yamllint .` passed.
- `./scripts/validation/validate-repository.sh` passed static Kustomize and
  kubeconform checks in this environment.
- `git diff --check` passed.

NOT RUN in this session:

- `/dev/kvm` runtime proof.
- Real K3s installation.
- Flux bootstrap or reconciliation.
- Live-cluster KubeVirt/CDI deployment checks.
- VM boot, guest SSH, guest HTTP, or container HTTP runtime reachability.
- KubeVirt server-side dry-run validation requiring a live
  `virtualmachines.kubevirt.io` CRD.

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

## Not executed or not yet empirically verified at this observation point

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

At this 2026-07-22 observation point, no runtime component was represented as
successful because later target-workstation evidence had not yet been
recorded.
