#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$repo_root"
errors=0

run() {
  echo "+ $*"
  if ! "$@"; then errors=$((errors + 1)); fi
}

if command -v shellcheck >/dev/null 2>&1; then
  mapfile -t shell_files < <(find scripts -type f -name '*.sh' -print)
  if (( ${#shell_files[@]} > 0 )); then run shellcheck "${shell_files[@]}"; fi
else
  echo '[WARN] shellcheck unavailable.'
fi

if command -v yamllint >/dev/null 2>&1; then
  run yamllint -c .yamllint .
else
  echo '[WARN] yamllint unavailable.'
fi

for path in \
  clusters/fluxvirt-lab \
  infrastructure/namespaces \
  infrastructure/kubevirt/operator \
  infrastructure/kubevirt/cr \
  infrastructure/cdi/operator \
  infrastructure/cdi/cr \
  infrastructure/cdi/storage-profile \
  virtual-machines/ubuntu-legacy-web \
  apps/container-demo \
  workloads; do
  if command -v kubectl >/dev/null 2>&1; then
    if output=$(kubectl kustomize "$path" 2>&1); then
      echo "+ kubectl kustomize $path"
    elif grep -Eq 'no such file or directory|must resolve to a file' <<<"$output" && [[ "$path" == infrastructure/cdi/* ]]; then
      echo "[WARN] CDI release assets are absent; run make vendor before enabling CDI."
    else
      echo "$output" >&2
      errors=$((errors + 1))
    fi
  else
    echo "[WARN] kubectl unavailable; skipped Kustomize build for $path."
  fi
done

if command -v kubeconform >/dev/null 2>&1 && command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize apps/container-demo | run kubeconform -strict -summary
  kubectl kustomize virtual-machines/ubuntu-legacy-web | run kubeconform -ignore-missing-schemas -summary
elif ! command -v kubeconform >/dev/null 2>&1; then
  echo '[WARN] kubeconform unavailable; schema validation was skipped.'
else
  echo '[WARN] kubectl unavailable; generated-manifest validation was skipped.'
fi

if (( errors > 0 )); then
  echo "Validation failed with $errors error group(s)." >&2
  exit 1
fi

echo 'Static repository validation passed for the tools that were installed.'
