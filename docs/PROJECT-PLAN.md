# FluxVirt Lab — Windows 11 Home implementation plan

## Executive decision

| Decision | Selected baseline |
|---|---|
| Project | FluxVirt Lab |
| Physical host | Windows 11 Home x86_64 |
| Outer OS | Ubuntu Server 24.04.4 LTS |
| Primary hypervisor | Oracle VirtualBox 7.2 Platform Package |
| Required execution mode | Native VT-x/AMD-V with nested hardware virtualization enabled |
| Same-host degraded fallback | KubeVirt software emulation, explicitly labeled degraded |
| Best technical fallback | Dual-boot Linux with KVM/libvirt, or dedicated Proxmox VE hardware |
| Kubernetes | K3s v1.35.6+k3s1, single node |
| CNI | K3s Flannel |
| MVP storage | local-path, node-bound |
| GitOps | Flux v2.9.2 |
| Virtualization | KubeVirt v1.8.4 + CDI v1.65.0 |
| Recommended outer VM | 8 vCPU, 16 GiB RAM, 150 GiB dynamically allocated VDI |
| Primary networking | VirtualBox NAT with localhost port forwards |
| Principal limitation | Nested KVM depends on VirtualBox receiving VT-x/AMD-V directly |

## Project vision

FluxVirt Lab demonstrates a nested, GitOps-operated hybrid platform on Windows 11 Home: VirtualBox hosts Ubuntu Server; Ubuntu runs K3s; Flux reconciles Kubernetes, KubeVirt, CDI, one Linux VM, and one container application from Git. The project emphasizes reproducibility, explicit host-mode trade-offs, preflight gates, and evidence instead of claiming production availability.

## Windows Home constraint

The full Hyper-V role is unavailable on Windows 11 Home. VirtualBox is therefore a first-class dependency rather than a fallback. Windows Home can nevertheless run the Microsoft hypervisor through WSL2, Virtual Machine Platform, Windows Hypervisor Platform, Memory Integrity, or VBS. When that hypervisor is active, VirtualBox may use a compatibility backend and nested KVM can fail.

The preferred operating model is:

1. Keep the normal Windows boot entry for daily use, WSL2, and security features.
2. Treat CPU virtualization fields as deferred—not failed—while `HypervisorPresent=True`.
3. Add a dedicated FluxVirt boot entry with `hypervisorlaunchtype off` and `vsmlaunchtype off`.
4. Boot that entry only when running the lab.
5. Verify `HypervisorPresent=False` and rerun the native hardware checks before installing VirtualBox.
6. Verify `/dev/kvm` inside Ubuntu before installing K3s.

No script automatically changes BCD, VBS, Memory Integrity, or WSL2 settings.

## Professional value

The lab demonstrates Linux administration, VirtualBox automation, nested virtualization, Windows host diagnostics, Kubernetes operations, Flux reconciliation, KubeVirt VM lifecycle, CDI image import, cloud-init, CI validation, security controls, capacity planning, documentation, and incident-oriented troubleshooting.

## Phase scope

### MVP

- Prove physical CPU extensions and firmware virtualization.
- Prove that the Microsoft hypervisor is not active in the dedicated lab boot session.
- Create a reproducible VirtualBox Ubuntu VM with nested VT-x/AMD-V enabled.
- Prove CPU flags, `/dev/kvm`, KVM modules, and KubeVirt allocatable devices.
- Build one Ubuntu/K3s node.
- Bootstrap Flux and reconcile KubeVirt/CDI in dependency order.
- Run one Ubuntu KubeVirt guest and one hardened container workload.
- Publish architecture, installation, evidence, and troubleshooting documentation.

### Intermediate

- Automate Ubuntu configuration with Ansible.
- Add SOPS with age, Kyverno, Prometheus/Grafana, Trivy, secret scanning, and tested backup/restore.
- Add a VirtualBox host-only adapter only when direct guest addressing provides concrete value.

### Advanced

- Move to multiple Ubuntu nodes on dedicated Proxmox/KVM hardware.
- Introduce migration-capable RWX/block storage, live migration, multi-tenancy, VM templates, Loki/Tempo/OpenTelemetry, self-service, signing, and DR exercises.

## Progressive roadmap

| Stage | Objective | Main files | Validation | Rollback |
|---|---|---|---|---|
| 0 | Windows Home inventory | `check-host-virtualization.ps1`, `docs/WINDOWS-HOME.md` | normal boot may exit `2`; lab boot returns `0`, reports no Microsoft hypervisor, and exposes reliable hardware fields | boot the normal Windows entry |
| 1 | VirtualBox readiness | `check-virtualbox-readiness.ps1` | VirtualBox 7.2 found; VM nested setting is enabled | no change |
| 2 | Outer VM | VirtualBox creation script | VM boots Ubuntu installer | unregister only the named VM after review |
| 3 | Ubuntu baseline | `configure-ubuntu.sh` | SSH, NTP, firewall, modules | reinstall or restore a deliberate snapshot |
| 4 | Nested KVM | `check-ubuntu-kvm.sh` | `/dev/kvm` usable | correct host mode; do not continue |
| 5 | K3s | `install-k3s.sh` | node `Ready`, local-path present | use official uninstall only after data warning |
| 6 | GitOps | `bootstrap-flux.sh` | `flux check`, sources ready | suspend/delete Flux resources deliberately |
| 7 | KubeVirt/CDI | vendored manifests + Flux graph | CRs available, KVM resource allocatable | revert Git commit |
| 8 | VM and container | `virtual-machines/`, `apps/` | VMI Running, DV Succeeded, HTTP probes pass | revert Git commit |
| 9 | Quality | workflow + validation script | checks green | fix on branch |
| 10 | Evidence and rebuild | docs and demo | repeatable demo and clean rebuild | restore backed-up persistent data |

## Acceptance criteria

### Hardware-accelerated MVP done

- Windows Home host preflight output is saved as evidence.
- The dedicated lab boot reports `HypervisorPresent=False`.
- VirtualBox reports nested hardware virtualization enabled for `fluxvirt-lab`.
- Ubuntu can be recreated from the documented VirtualBox settings.
- `vmx` or `svm` is visible inside Ubuntu.
- `/dev/kvm` exists, KVM modules load, and the current user can access the device.
- K3s node is Ready and version matches the pin.
- Flux reconciliation is healthy.
- KubeVirt and CDI are Available.
- `devices.kubevirt.io/kvm` is allocatable.
- DataVolume completes, VM/VMI runs, cloud-init user works, and VM HTTP/SSH are reachable.
- Container Deployment is Available and its forwarded NodePort responds.
- Repository checks pass and no private credential is committed.
- A clean rebuild has been demonstrated.

### Degraded learning mode

A software-emulation deployment may be used to continue learning only when:

- it is clearly labeled `DEGRADED — KUBEVIRT EMULATION`;
- no KVM performance, migration, or hardware-acceleration claim is made;
- the hardware-accelerated MVP remains open and incomplete.

### Intermediate done

OS configuration, secrets, policies, vulnerability scanning, monitoring, and backup restore are automated and tested.

### Advanced done

At least one advanced capability is empirically validated, capacity limits are recorded, and roadmap features are never presented as implemented.

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Microsoft hypervisor remains active | High when WSL2/VBS is used | Blocking | dedicated boot entry; verify `HypervisorPresent=False` |
| VirtualBox cannot expose nested VT-x/AMD-V | Medium | Blocking | update BIOS/VirtualBox; validate VM setting; use Linux KVM/Proxmox fallback |
| WSL2 unavailable during lab boot | Certain in native VirtualBox mode | Medium | use normal Windows boot entry outside lab sessions |
| Security posture reduced in lab boot | Medium | High | isolated boot entry; no untrusted browsing/workloads; return to normal boot afterward |
| Outer VM memory pressure | Medium | High | 16 GiB baseline, stage observability, resource limits |
| VM image fills disk | Medium | High | 150 GiB baseline, disk alerts, cleanup runbook |
| local-path node loss | Medium | High | Git for desired state, separate VM-disk backup, migrate storage later |
| Scope creep | High | Medium | milestone gates; exclude advanced stack from MVP |
| Version drift | Medium | High | central pins, ADRs, upgrade branch and compatibility validation |

## GitHub milestones

- `v0.1.0-windows-home-preflight`
- `v0.2.0-virtualbox-ubuntu-lab`
- `v0.3.0-kubernetes`
- `v0.4.0-flux-bootstrap`
- `v0.5.0-kubevirt-mvp`
- `v1.0.0-portfolio-release`
