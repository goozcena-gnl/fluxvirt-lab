#!/usr/bin/env bash
set -Eeuo pipefail

kubectl get nodes -o wide
kubectl get pods -A

if command -v flux >/dev/null 2>&1; then
  flux check
  flux get all -A
else
  echo '[WARN] Flux CLI not installed.'
fi

kubectl -n kubevirt get kubevirt,deploy,ds,pods 2>/dev/null || true
kubectl -n cdi get cdi,deploy,pods 2>/dev/null || true
kubectl get node -o custom-columns=NAME:.metadata.name,KVM:.status.allocatable.devices\.kubevirt\.io/kvm
kubectl -n vm-workloads get vm,vmi,dv,pvc,svc 2>/dev/null || true
kubectl -n demo get deploy,pods,svc 2>/dev/null || true
