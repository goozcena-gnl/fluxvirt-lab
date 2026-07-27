#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
# shellcheck disable=SC1091
source "$repo_root/versions.env"

"$repo_root/scripts/preflight/check-ubuntu-kvm.sh"

if command -v k3s >/dev/null 2>&1; then
  echo 'K3s is already installed. Refusing to overwrite it automatically.' >&2
  k3s --version || true
  exit 2
fi

sudo install -d -m 0755 /etc/rancher/k3s
cat <<'EOF' | sudo tee /etc/rancher/k3s/config.yaml >/dev/null
write-kubeconfig-mode: "0640"
disable:
  - traefik
  - servicelb
node-label:
  - "fluxvirt.dev/role=lab"
protect-kernel-defaults: false
EOF

curl -fsSL https://get.k3s.io -o /tmp/install-k3s.sh
chmod 0755 /tmp/install-k3s.sh
sudo env INSTALL_K3S_VERSION="$K3S_VERSION" INSTALL_K3S_EXEC="server" /tmp/install-k3s.sh
rm -f /tmp/install-k3s.sh

mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$USER:$USER" "$HOME/.kube/config"
chmod 0600 "$HOME/.kube/config"
export KUBECONFIG="$HOME/.kube/config"

profile_line="export KUBECONFIG=\"\$HOME/.kube/config\""
grep -qxF "$profile_line" "$HOME/.profile" ||   printf '\n%s\n' "$profile_line" >> "$HOME/.profile"

wait_for_kubernetes_api_and_node() {
  local deadline=$((SECONDS + 300))

  while (( SECONDS < deadline )); do
    if kubectl get --raw='/readyz' >/dev/null 2>&1 &&
       [[ -n $(kubectl get nodes --no-headers 2>/dev/null) ]]; then
      return 0
    fi

    sleep 5
  done

  return 1
}

echo '[INFO] Waiting for Kubernetes API readiness and initial Node registration.'

if ! wait_for_kubernetes_api_and_node; then
  echo '[ERROR] Kubernetes API or initial Node did not become available within 300 seconds.' >&2
  sudo systemctl status k3s --no-pager --full || true
  exit 1
fi

kubectl wait --for=condition=Ready node --all --timeout=300s
kubectl get nodes -o wide

echo "K3s $K3S_VERSION installed. This confirms Kubernetes only; KubeVirt is not yet installed or validated."
