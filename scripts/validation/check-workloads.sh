#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)

cd "$repo_root"

node_ip=${NODE_IP:-10.0.2.15}
failures=0

pass() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  failures=$((failures + 1))
}

expect_equal() {
  local label=$1
  local actual=$2
  local expected=$3

  if [[ "$actual" == "$expected" ]]; then
    pass "${label}: ${actual}"
  else
    fail "${label}: expected '${expected}', got '${actual:-<empty>}'"
  fi
}

for command_name in kubectl curl awk; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf '[ERROR] Required command unavailable: %s\n' \
      "$command_name" >&2
    exit 2
  fi
done

required_kustomizations=(
  flux-system
  namespaces
  kubevirt-operator
  kubevirt-cr
  cdi-operator
  cdi-cr
  cdi-storage-profile
  ubuntu-legacy-web
  container-demo
)

for name in "${required_kustomizations[@]}"; do
  ready=$(
    kubectl -n flux-system get \
      kustomizations.kustomize.toolkit.fluxcd.io "$name" \
      -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' \
      2>/dev/null ||
      true
  )

  expect_equal \
    "Flux Kustomization ${name}" \
    "$ready" \
    "True"
done

if kubectl -n flux-system get \
  kustomizations.kustomize.toolkit.fluxcd.io workloads \
  >/dev/null 2>&1; then
  fail "Obsolete workloads Kustomization is present"
else
  pass "Obsolete workloads Kustomization is absent"
fi

vm_ready=$(
  kubectl -n vm-workloads get vm ubuntu-legacy-web \
    -o jsonpath='{.status.ready}' \
    2>/dev/null ||
    true
)

vmi_phase=$(
  kubectl -n vm-workloads get vmi ubuntu-legacy-web \
    -o jsonpath='{.status.phase}' \
    2>/dev/null ||
    true
)

agent_connected=$(
  kubectl -n vm-workloads get vmi ubuntu-legacy-web \
    -o jsonpath='{.status.conditions[?(@.type=="AgentConnected")].status}' \
    2>/dev/null ||
    true
)

dv_phase=$(
  kubectl -n vm-workloads get datavolume \
    ubuntu-legacy-web-rootdisk \
    -o jsonpath='{.status.phase}' \
    2>/dev/null ||
    true
)

pvc_phase=$(
  kubectl -n vm-workloads get pvc \
    ubuntu-legacy-web-rootdisk \
    -o jsonpath='{.status.phase}' \
    2>/dev/null ||
    true
)

expect_equal "VirtualMachine ready" "$vm_ready" "true"
expect_equal "VirtualMachineInstance phase" "$vmi_phase" "Running"
expect_equal "QEMU guest agent" "$agent_connected" "True"
expect_equal "DataVolume phase" "$dv_phase" "Succeeded"
expect_equal "PVC phase" "$pvc_phase" "Bound"

ready_replicas=$(
  kubectl -n demo get deployment container-demo \
    -o jsonpath='{.status.readyReplicas}' \
    2>/dev/null ||
    true
)

available_replicas=$(
  kubectl -n demo get deployment container-demo \
    -o jsonpath='{.status.availableReplicas}' \
    2>/dev/null ||
    true
)

pod_phase=$(
  kubectl -n demo get pods \
    -l app.kubernetes.io/name=container-demo \
    -o jsonpath='{.items[0].status.phase}' \
    2>/dev/null ||
    true
)

pod_restarts_before=$(
  kubectl -n demo get pods \
    -l app.kubernetes.io/name=container-demo \
    -o jsonpath='{range .items[*].status.containerStatuses[*]}{.restartCount}{"\\n"}{end}' \
    2>/dev/null |
    awk '{total += $1} END {print total + 0}'
)

restart_stability_seconds=${RESTART_STABILITY_SECONDS:-15}

sleep "$restart_stability_seconds"

pod_restarts_after=$(
  kubectl -n demo get pods \
    -l app.kubernetes.io/name=container-demo \
    -o jsonpath='{range .items[*].status.containerStatuses[*]}{.restartCount}{"\\n"}{end}' \
    2>/dev/null |
    awk '{total += $1} END {print total + 0}'
)

expect_equal "Container ready replicas" "$ready_replicas" "1"
expect_equal "Container available replicas" "$available_replicas" "1"
expect_equal "Container Pod phase" "$pod_phase" "Running"

if [[ "$pod_restarts_before" == "$pod_restarts_after" ]]; then
  pass \
    "Container restart count stable: ${pod_restarts_before} over ${restart_stability_seconds}s"
else
  fail \
    "Container restart count increased: ${pod_restarts_before} -> ${pod_restarts_after}"
fi

vm_response=$(
  curl -fsS \
    --connect-timeout 10 \
    "http://${node_ip}:30080/" ||
    true
)

container_response=$(
  curl -fsS \
    --connect-timeout 10 \
    "http://${node_ip}:30081/" ||
    true
)

expect_equal \
  "VM HTTP response" \
  "$vm_response" \
  "<h1>FluxVirt KubeVirt VM</h1>"

expect_equal \
  "Container HTTP response" \
  "$container_response" \
  "FluxVirt container workload"

if ./scripts/preflight/check-kubevirt-readiness.sh; then
  pass "KubeVirt platform readiness"
else
  fail "KubeVirt platform readiness"
fi

if (( failures > 0 )); then
  printf '\nAcceptance failed with %d error(s).\n' \
    "$failures" >&2
  exit 1
fi

printf '\n[PASS] End-to-end FluxVirt workload acceptance passed.\n'
