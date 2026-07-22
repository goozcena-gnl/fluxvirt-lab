# Ubuntu Server baseline

- Release: Ubuntu Server 24.04.4 LTS, minimal installation with OpenSSH.
- Hostname: `fluxvirt-lab`.
- Filesystem: default guided LVM/ext4 is adequate for the MVP; retain free volume-group capacity if resizing is expected.
- Swap: leave the installer default only if K3s starts successfully; document any change rather than applying an unexplained blanket disable.
- Time: systemd-timesyncd/NTP enabled.
- Access: SSH public keys; disable password authentication after proving key access.
- Firewall: SSH, Kubernetes API from management subnet, and selected NodePorts only.
- Kernel: `overlay`, `br_netfilter`, KVM Intel/AMD module, IP forwarding.
- Security: keep AppArmor enabled; do not weaken it globally to solve component-specific problems.
- Users: one named administrative user with sudo and `kvm` membership; no shared root password.
