# FluxVirt Lab

> **Status:** **Phase 0 host validation passed on 2026-07-22** on Windows 11 Home Insider Preview. Native VT-x, SLAT, and firmware virtualization are verified; `HypervisorPresent=False`; VBS/HVCI is inactive in the lab boot. VirtualBox, Ubuntu, `/dev/kvm`, Kubernetes, Flux, KubeVirt, CDI, and workloads are not yet runtime-validated.

FluxVirt Lab is a Windows-hosted, Ubuntu-based cloud-native virtualization laboratory. Oracle VirtualBox runs one Ubuntu Server LTS virtual machine, Ubuntu runs a single-node K3s cluster, and Flux CD reconciles both containerized workloads and KubeVirt virtual machines from Git.

## Baseline architecture

```text
Windows 11 Home x86_64
└── Oracle VirtualBox 7.2.14 Platform Package
    └── Ubuntu Server 24.04.4 LTS
        └── K3s / Kubernetes 1.35
            ├── Flux CD 2.9.2
            ├── KubeVirt 1.8.4
            ├── CDI 1.65.0
            ├── Ubuntu KubeVirt guest
            └── Container demo workload
```

## Why VirtualBox

Windows 11 Home does not include the full Hyper-V role. The primary path is therefore the **Oracle VirtualBox 7.2.14 Platform Package**, whose base components are GPLv3 and whose CLI exposes nested VT-x/AMD-V through `--nested-hw-virt on`.

The design has an important host-mode constraint: WSL2, Virtual Machine Platform, Windows Hypervisor Platform, Memory Integrity, or another VBS feature can cause the Microsoft hypervisor to be active even on Windows Home. VirtualBox may still start through a compatibility backend, but nested KVM for KubeVirt must not be assumed to work in that mode.

The recommended approach is a separate Windows boot entry with `hypervisorlaunchtype off` and `vsmlaunchtype off` for FluxVirt Lab. However, Memory Integrity and the Windows optional-feature states are global settings: after this workstation required those global changes, WSL2/VBS must be explicitly restored when returning to the normal operating profile. Read `docs/WINDOWS-HOME.md` before changing boot configuration.

## Pinned compatibility baseline

| Component | Baseline |
|---|---:|
| Host | Windows 11 Home x86_64 |
| Hypervisor | Oracle VirtualBox 7.2.14 Platform Package |
| Ubuntu Server | 24.04.4 LTS |
| K3s | v1.35.6+k3s1 |
| Kubernetes | v1.35.6 |
| Flux | v2.9.2 |
| KubeVirt | v1.8.4 |
| CDI | v1.65.0 |

See `config/versions.yaml` and the ADRs before upgrading.

## MVP boundaries

The MVP intentionally excludes multi-node Kubernetes, live migration, Longhorn/Rook-Ceph, Backstage, Loki, Tempo, OpenTelemetry, MetalLB, and high availability. The first target is one hardware-accelerated KubeVirt VM and one containerized application on one Ubuntu/K3s node.

Software emulation is documented only as a degraded learning fallback. It does not satisfy the hardware-accelerated MVP acceptance criteria.

## Start here

1. Read `docs/WINDOWS-HOME.md` and ensure that any device-encryption recovery information is available before changing Windows boot configuration.
2. Run the Windows host preflight in an elevated PowerShell terminal:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\preflight\check-host-virtualization.ps1
   $LASTEXITCODE
   ```

   On the normal WSL2/VBS-enabled boot, exit code `2` is expected. When `HypervisorPresent=True`, the three CPU virtualization fields can be masked and must not be treated as BIOS failures. Create the separate lab boot entry in `docs/WINDOWS-HOME.md`, boot it, and rerun the script.

3. Install the pinned VirtualBox 7.2.14 **Platform Package only after the lab-boot preflight returns `0`**. The Extension Pack is not required.
4. Create the Ubuntu VM:

   ```powershell
   .\infrastructure\hypervisor\virtualbox\Create-FluxVirtLabVM.ps1 `
     -IsoPath 'C:\ISO\ubuntu-24.04.4-live-server-amd64.iso'
   ```

5. Install Ubuntu Server 24.04.4 LTS with OpenSSH enabled.
6. Run `scripts/preflight/check-ubuntu-kvm.sh` inside Ubuntu.
7. Do **not** install K3s until `/dev/kvm` exists and is accessible.
8. Before Flux bootstrap, run `make vendor`; CDI release assets are intentionally fetched and committed during this step.

## Repository map

- `infrastructure/hypervisor/virtualbox/`: Windows 11 Home VirtualBox provisioning.
- `infrastructure/ubuntu/`: Ubuntu baseline and VirtualBox NAT networking examples.
- `infrastructure/kubernetes/`: K3s installation.
- `infrastructure/kubevirt/`, `infrastructure/cdi/`: vendored platform manifests.
- `clusters/fluxvirt-lab/`: Flux reconciliation graph.
- `virtual-machines/`: KubeVirt VM and DataVolume definitions.
- `apps/`: containerized demonstration workload.
- `policies/`: optional Kyverno policies.
- `scripts/`: preflight, bootstrap, vendor, validation, and teardown helpers.
- `docs/`: project plan, Windows Home guidance, architecture, networking, GitOps, KubeVirt, security, observability, backup, troubleshooting, ADRs, roadmap, and portfolio copy.

## Safety rules

- Never commit PATs, private SSH keys, kubeconfigs, SOPS private age keys, passwords, or VM credentials.
- Replace every `REPLACE_ME` placeholder before deployment.
- Review scripts before running them as Administrator or with `sudo`.
- Do not silently disable Memory Integrity, VBS, WSL2, or Windows virtualization features.
- Git is the source of desired Kubernetes state; persistent VM disks still require separate backup.

## License

Apache-2.0 for original repository content. Vendored upstream manifests retain their upstream licenses.
