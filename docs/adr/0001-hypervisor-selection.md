# ADR 0001: Hypervisor selection for Windows 11 Home

- Status: Accepted for MVP
- Date: 2026-07-22

## Context

The physical host is Windows 11 Home. The full Hyper-V role is unavailable on this edition. KubeVirt inside Ubuntu requires a reliable nested-virtualization path that produces a usable `/dev/kvm` device. WSL2, Virtual Machine Platform, Windows Hypervisor Platform, Memory Integrity, and VBS can still activate the Microsoft hypervisor on Windows Home.

## Decision

Use the Oracle VirtualBox 7.2 Platform Package as the primary hypervisor. Configure the Ubuntu VM with `--nested-hw-virt on`. Use a separate Windows lab boot entry with `hypervisorlaunchtype off` and `vsmlaunchtype off` so the normal boot entry remains available for WSL2 and normal security operation. While `HypervisorPresent=True`, defer the Win32_Processor virtualization fields because they can be masked by the running Microsoft hypervisor.

Do not require the VirtualBox Extension Pack. Do not include an unsupported Hyper-V provisioning script. Treat software emulation as degraded only. Treat Linux KVM/libvirt or Proxmox VE as the preferred fallback if VirtualBox cannot expose `/dev/kvm`.

## Consequences

- The primary host-side tooling remains free and predominantly open source.
- WSL2 does not operate during the dedicated native-VirtualBox boot session.
- VBS-backed protections are not active in that session, so the lab session must be treated as a controlled environment.
- Nested acceleration remains unverified until Ubuntu passes `/dev/kvm` checks.
- The MVP cannot be marked complete in emulation mode.
