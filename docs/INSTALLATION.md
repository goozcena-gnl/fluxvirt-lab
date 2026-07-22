# Installation runbook — Windows 11 Home

## Phase 0 — host preflight

1. Read `docs/WINDOWS-HOME.md` and confirm that the device-encryption/BitLocker recovery key is available.
2. From the normal Windows boot, open elevated PowerShell and run:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\preflight\check-host-virtualization.ps1
   $LASTEXITCODE
   ```

3. If the script returns `2`, this means the Microsoft hypervisor/VBS owns VT-x/AMD-V in the current boot. The CPU fields may display `False`; they are deferred, not treated as physical failures.
4. Create the dedicated **Windows 11 Home - FluxVirt Lab** boot entry using `docs/WINDOWS-HOME.md`.
5. Reboot into that entry and rerun the same preflight.
6. Continue only when the script returns `0` and reports `HypervisorPresent=False`.

Exit codes:

- `0`: native-boot hardware checks pass and the Microsoft hypervisor is not active.
- `1`: an actual physical hardware or firmware requirement failed while the Microsoft hypervisor was not active.
- `2`: the Microsoft hypervisor is active; hardware fields are not reliable in this boot and native VirtualBox nested acceleration is blocked.

## Phase 1 — install VirtualBox and create the outer VM

Install the pinned Oracle VirtualBox 7.2.14 Platform Package. The Extension Pack is not required.

```powershell
# Verify the downloaded installers before execution.
Get-FileHash 'C:\Downloads\VirtualBox-7.2.14-174565-Win.exe' -Algorithm SHA256
Get-FileHash 'C:\ISO\ubuntu-24.04.4-live-server-amd64.iso' -Algorithm SHA256

.\infrastructure\hypervisor\virtualbox\Create-FluxVirtLabVM.ps1 `
  -IsoPath 'C:\ISO\ubuntu-24.04.4-live-server-amd64.iso'

.\scripts\preflight\check-virtualbox-readiness.ps1

VBoxManage startvm fluxvirt-lab --type gui
```

Install Ubuntu Server with OpenSSH enabled. Keep the default DHCP configuration on the first VirtualBox NAT adapter.

## Phase 2 — prove nested KVM

After cloning the repository inside Ubuntu:

```bash
./scripts/bootstrap/configure-ubuntu.sh
# Log out and back in so kvm-group membership is refreshed.
./scripts/preflight/check-ubuntu-kvm.sh
```

Proceed only when `/dev/kvm` exists, KVM modules are loaded, and the current user can access the device.

## Phase 3 — install K3s

```bash
./scripts/bootstrap/install-k3s.sh
kubectl get nodes -o wide
```

## Phase 4 — install Flux CLI and vendor platform manifests

```bash
./scripts/bootstrap/install-flux-cli.sh
./scripts/vendor/vendor-platform-manifests.sh
```

Commit the vendored files before bootstrap so the cluster can reconcile them from Git.

## Phase 5 — bootstrap Flux

```bash
export GITHUB_USER='REPLACE_ME'
export GITHUB_REPO='fluxvirt-lab'
read -rsp 'GitHub token: ' GITHUB_TOKEN && export GITHUB_TOKEN && echo
./scripts/bootstrap/bootstrap-flux.sh
unset GITHUB_TOKEN
```

## Phase 6 — deploy KubeVirt, CDI, VM, and app

Flux applies resources in dependency order. Replace the public SSH-key placeholder before merging workloads.

```bash
flux get kustomizations -A
./scripts/preflight/check-kubevirt-readiness.sh
kubectl -n vm-workloads get vm,vmi,dv,pvc
kubectl -n demo get deploy,pods,svc
```

## Phase 7 — reach workloads from Windows

VirtualBox NAT forwarding created by the provisioning script exposes:

```text
Ubuntu SSH:        ssh -p 2222 <ubuntu-user>@127.0.0.1
Kubernetes API:   127.0.0.1:6443 (optional; management from Ubuntu is preferred)
Container app:    http://127.0.0.1:30081
KubeVirt VM web:  http://127.0.0.1:30080
KubeVirt VM SSH:  ssh -p 30022 devops@127.0.0.1
```

These endpoints become valid only after the corresponding readiness and connectivity tests pass.
