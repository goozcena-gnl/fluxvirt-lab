# Troubleshooting matrix

| Symptom | Diagnostics | Likely cause | Safe remediation |
|---|---|---|---|
| CPU fields show `False` while `HypervisorPresent=True` | `Win32_ComputerSystem`, `Win32_Processor` | Microsoft hypervisor masks or owns the virtualization requirement fields | do not diagnose BIOS from this boot; create/select the dedicated lab entry and rerun |
| Host script exits `1` | `HypervisorPresent=False` plus CPU CIM fields | real native-boot VT-x/AMD-V, SLAT, or firmware failure | enable virtualization in BIOS/UEFI; update firmware if appropriate |
| Host script exits `2` | `Get-CimInstance Win32_ComputerSystem` | Microsoft hypervisor/VBS active; hardware checks deferred | boot the dedicated FluxVirt entry; review `docs/WINDOWS-HOME.md` |
| WSL2 does not start in lab boot | `wsl --status` | `hypervisorlaunchtype off` by design | reboot into the normal Windows entry |
| `VBoxManage` missing | `Get-Command VBoxManage.exe` | VirtualBox not installed or PATH incomplete | install VirtualBox 7.2 Platform Package; reopen terminal |
| Nested setting not enabled | `VBoxManage showvminfo fluxvirt-lab` | VM created without nested setting | power off VM; run `VBoxManage modifyvm fluxvirt-lab --nested-hw-virt on` |
| VirtualBox VM slow or nested KVM fails | `HypervisorPresent`, VBox log | VirtualBox using Microsoft-hypervisor backend | use dedicated lab boot; do not claim acceleration |
| `vmx`/`svm` absent in Ubuntu | `lscpu`, `/proc/cpuinfo` | extensions not exposed to guest | power off VM, verify host mode and nested setting |
| `/dev/kvm` absent | `lsmod`, `dmesg | grep -i kvm` | KVM modules cannot initialize | fix nested virtualization; load `kvm_intel` or `kvm_amd` |
| Permission denied on `/dev/kvm` | `ls -l /dev/kvm`, `id` | user not in `kvm` group | add user to group and start a new login session |
| KubeVirt unavailable | `kubectl -n kubevirt get pods`, operator logs | operator, resource, or KVM issue | resolve failed pods and verify allocatable KVM resource |
| `devices.kubevirt.io/kvm` empty | node allocatable resources, virt-handler logs | KVM device plugin unhealthy | recheck `/dev/kvm`, permissions, modules, outer hypervisor |
| DataVolume pending | DV/PVC events, CDI importer logs | storage class, capacity, URL, DNS | validate `local-path`, free space, URL, and certificates |
| PVC pending | `kubectl describe pvc` | no default class or provisioner failure | verify local-path provisioner and default annotation |
| VM stuck Scheduling | VMI events, node allocatable | insufficient CPU/RAM/KVM | reduce VM request or increase outer VM resources |
| VM has no network | VMI interface status, guest console | cloud-init/network or service selector issue | validate masquerade interface, guest DHCP, and selector |
| Windows forwarded port unavailable | `VBoxManage showvminfo`, `Test-NetConnection` | NAT rule missing or service not listening | verify NAT rules and Kubernetes Service endpoints |
| SSH unavailable | VM console, Service endpoints | key placeholder, sshd, cloud-init incomplete | inspect cloud-init logs and replace the public key |
| Flux reconciliation failure | `flux get all -A`, controller logs | invalid YAML, dependency, auth | fix Git source or manifest and reconcile again |
| Disk full | `df -h`, `du`, PVCs, images | CDI imports and VM disks consumed VDI | remove unused DataVolumes safely or expand storage |

Software emulation is a diagnostic fallback only. A lab using emulation must be labeled degraded and must not claim KVM performance or migration validation.
