#!/usr/bin/env bash
set -Eeuo pipefail

errors=0
fail() { echo "[FAIL] $*" >&2; errors=$((errors + 1)); }
pass() { echo "[PASS] $*"; }

kubectl get nodes >/dev/null || { echo '[FAIL] Kubernetes is unavailable.' >&2; exit 1; }

if kubectl -n kubevirt wait kubevirt/kubevirt --for=condition=Available --timeout=10s >/dev/null 2>&1; then
  pass 'KubeVirt reports Available.'
else
  fail 'KubeVirt does not report Available.'
fi

allocatable=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.allocatable.devices\.kubevirt\.io/kvm}{"\n"}{end}' 2>/dev/null || true)
# Kubernetes resource quantities can be serialized with decimal SI
# suffixes. For example, KubeVirt commonly exposes 1000 devices as "1k".
# Extended device resources must still represent a positive integral count.
if grep -Eq '^[1-9][0-9]*(k|M|G|T|P|E)?$' <<<"$allocatable"; then
  reported=$(
    tr '\n' ',' <<<"$allocatable" |
      sed 's/,$//'
  )
  pass "At least one KVM device is allocatable to KubeVirt: ${reported}."
else
  fail "No positive allocatable devices.kubevirt.io/kvm quantity was found: ${allocatable:-unset}."
fi

if kubectl -n kubevirt get ds virt-handler >/dev/null 2>&1; then
  desired=$(kubectl -n kubevirt get ds virt-handler -o jsonpath='{.status.desiredNumberScheduled}')
  ready=$(kubectl -n kubevirt get ds virt-handler -o jsonpath='{.status.numberReady}')
  if [[ "$desired" == "$ready" && "$ready" != 0 ]]; then
    pass 'virt-handler is ready.'
  else
    fail "virt-handler ready=$ready desired=$desired"
  fi
else
  fail 'virt-handler DaemonSet is missing.'
fi

(( errors == 0 )) || exit 1
