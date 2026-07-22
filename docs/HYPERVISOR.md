# Hypervisor decision for Windows 11 Home

## Decision

Use the **Oracle VirtualBox 7.2 Platform Package** as the primary hypervisor. Run it in native VT-x/AMD-V mode and enable `--nested-hw-virt on` for the Ubuntu VM. The dedicated lab boot sets both `hypervisorlaunchtype off` and `vsmlaunchtype off`; the normal boot remains unchanged. Do not use the proprietary Extension Pack because the MVP requires none of its features.

The full Hyper-V role is not available on Windows 11 Home, so the repository contains no Hyper-V provisioning workflow.

| Option | Windows 11 Home | Open-source status | Nested virtualization for this design | Automation | Decision |
|---|---|---|---|---|---|
| VirtualBox 7.2 Platform Package | Supported on x86_64 | GPLv3 base components | Available with `--nested-hw-virt on`; must be proven by `/dev/kvm` | `VBoxManage`, PowerShell | **Primary** |
| Hyper-V role | Not available | Proprietary | Not applicable on Home | PowerShell | Unsupported on this host |
| QEMU on Windows with WHPX | Possible | Open source | No clearer or more reliable nested-KVM path for this lab | CLI | Not selected |
| VMware Workstation | May be free but proprietary | Proprietary | Possible, still sensitive to Windows hypervisor mode | CLI/GUI | Not selected by OSS-first policy |
| Linux KVM/libvirt | Requires Linux host or dual boot | Open source | Best technical path | `virsh`, `virt-install`, Ansible | Best fallback |
| Proxmox VE | Requires dedicated/bare-metal host | Predominantly open source | Strong KVM path | API, CLI, OpenTofu providers | Advanced option |

## Windows Home host modes

### Mode A — hardware-accelerated target

Use a dedicated Windows boot entry where the Microsoft hypervisor and Virtual Secure Mode are not launched. In that session:

- WSL2 will not work;
- VBS-backed features such as Memory Integrity will not be active;
- VirtualBox can request VT-x/AMD-V directly;
- the Ubuntu guest may expose `/dev/kvm`.

This is the only mode that can satisfy the accelerated MVP acceptance criteria.

### Mode B — normal Windows session

Keep the normal boot entry for everyday use, WSL2, and your normal security posture. VirtualBox may run through a Windows-hypervisor compatibility backend, but nested KVM is not guaranteed. Do not accept this mode as successful unless the Ubuntu preflight proves `/dev/kvm`.

### Mode C — degraded KubeVirt emulation

Keep the normal Windows session and use KubeVirt software emulation only as a temporary educational fallback. Mark the environment degraded and exclude performance and migration claims.

## Recommended VirtualBox VM profile

- VM name: `fluxvirt-lab`
- Guest type: Ubuntu 64-bit
- Firmware: EFI
- Static memory: 16 GiB
- Virtual CPUs: 8
- Disk: 150 GiB dynamically allocated VDI
- Nested VT-x/AMD-V: enabled
- I/O APIC: enabled
- Network: VirtualBox NAT with explicit localhost port forwards
- Automatic snapshots: not used as a backup substitute
- Extension Pack: not installed or required

## Required validation chain

```text
BIOS/UEFI VT-x or AMD-V
  → Windows reports firmware virtualization
  → dedicated lab boot reports HypervisorPresent=False
  → native-boot CPU/firmware fields are re-evaluated
  → VirtualBox VM reports nested-hw-virt=on
  → Ubuntu sees vmx/svm
  → KVM modules load
  → /dev/kvm exists and is accessible
  → KubeVirt advertises devices.kubevirt.io/kvm
```

A failure at any step blocks the accelerated MVP.

## References

- [Microsoft: Install Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/install-hyper-v) — Windows Home does not include the full Hyper-V role.
- [Oracle VirtualBox 7.2: About VirtualBox](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/Introduction.html) — licensing, supported host model, and competing-hypervisor warning.
- [Oracle VirtualBox 7.2: Installing VirtualBox](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/installation.html) — Windows 11 x86_64 host support.
- [Oracle VirtualBox 7.2: Working with VMs](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/working-with-vms.html) — Nested VT-x/AMD-V setting.
- [Oracle VirtualBox 7.2: VBoxManage reference](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/vboxmanage.html) — `--nested-hw-virt=on`.
