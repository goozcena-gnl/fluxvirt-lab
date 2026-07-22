#!/usr/bin/env bash
set -Eeuo pipefail

errors=0
warns=0
pass() { printf '\033[32m[PASS]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; warns=$((warns + 1)); }
fail() { printf '\033[31m[FAIL]\033[0m %s\n' "$*"; errors=$((errors + 1)); }
info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }

info 'CPU and virtualization summary'
lscpu || true

flags=$(grep -Eoc '(vmx|svm)' /proc/cpuinfo || true)
if (( flags > 0 )); then pass "Virtualization CPU flag is visible in $flags processor entries."
else fail 'Neither vmx nor svm is visible. The outer hypervisor is not exposing virtualization extensions.'; fi

if [[ -c /dev/kvm ]]; then
  pass '/dev/kvm exists as a character device.'
  ls -l /dev/kvm
else
  fail '/dev/kvm does not exist. Do not install KubeVirt yet.'
fi

if lsmod | grep -qE '^kvm(_intel|_amd)?\b'; then
  pass 'KVM kernel module is loaded.'
  lsmod | grep -E '^kvm' || true
else
  fail 'KVM kernel modules are not loaded.'
fi

if getent group kvm >/dev/null; then
  pass 'The kvm group exists.'
  if id -nG "$USER" | tr ' ' '\n' | grep -qx kvm; then
    pass "Current user '$USER' belongs to the kvm group."
  else
    warn "Current user '$USER' is not in the kvm group. Run: sudo usermod -aG kvm '$USER', then log out and back in."
  fi
else
  warn 'The kvm group does not exist yet.'
fi

if [[ -r /dev/kvm && -w /dev/kvm ]]; then
  pass 'Current user can read and write /dev/kvm.'
else
  fail 'Current user cannot read and write /dev/kvm.'
fi

if command -v kvm-ok >/dev/null 2>&1; then
  if kvm-ok; then pass 'kvm-ok reports usable acceleration.'; else fail 'kvm-ok failed.'; fi
else
  warn 'kvm-ok is unavailable. Install cpu-checker.'
fi

if command -v qemu-system-x86_64 >/dev/null 2>&1; then
  if qemu-system-x86_64 -accel help 2>/dev/null | grep -qx kvm; then
    pass 'QEMU reports the KVM accelerator.'
  else
    fail 'QEMU does not report the KVM accelerator.'
  fi
else
  warn 'qemu-system-x86_64 is unavailable. Install qemu-system-x86.'
fi

printf '\nSummary: %d error(s), %d warning(s).\n' "$errors" "$warns"
if (( errors > 0 )); then
  echo 'Nested-virtualization preflight FAILED. Stop here and remediate the host/hypervisor chain.'
  exit 1
fi

echo 'Nested-virtualization preflight PASSED. K3s installation may proceed.'
