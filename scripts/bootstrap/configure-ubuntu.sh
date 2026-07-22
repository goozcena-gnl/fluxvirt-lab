#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -eq 0 ]]; then
  echo 'Run this script as the normal administrative user, not directly as root.' >&2
  exit 2
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates curl git jq make unzip gnupg lsb-release \
  cpu-checker qemu-system-x86 qemu-utils libvirt-clients \
  open-iscsi nfs-common apparmor-utils ufw

sudo usermod -aG kvm "$USER"
sudo timedatectl set-ntp true

cat <<'EOF' | sudo tee /etc/modules-load.d/fluxvirt.conf >/dev/null
br_netfilter
overlay
EOF

sudo modprobe br_netfilter
sudo modprobe overlay

cat <<'EOF' | sudo tee /etc/sysctl.d/99-fluxvirt-kubernetes.conf >/dev/null
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system >/dev/null

sudo ufw allow OpenSSH
sudo ufw allow from 10.0.2.0/24 to any port 6443 proto tcp
sudo ufw allow from 10.0.2.0/24 to any port 30000:32767 proto tcp
sudo ufw --force enable

echo 'Ubuntu baseline configured.'
echo 'Log out and back in so kvm-group membership takes effect, then rerun check-ubuntu-kvm.sh.'
