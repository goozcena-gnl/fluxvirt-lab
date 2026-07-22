#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
# shellcheck disable=SC1091
source "$repo_root/versions.env"

: "${GITHUB_USER:?Export GITHUB_USER.}"
: "${GITHUB_REPO:?Export GITHUB_REPO.}"
: "${GITHUB_TOKEN:?Export GITHUB_TOKEN only in the current shell.}"
: "${FLUX_VERSION:?FLUX_VERSION is missing from versions.env.}"

GITHUB_BRANCH=${GITHUB_BRANCH:-main}
FLUX_CLUSTER_PATH=${FLUX_CLUSTER_PATH:-clusters/fluxvirt-lab}

cleanup() {
  unset GITHUB_TOKEN
}
trap cleanup EXIT

command -v flux >/dev/null || {
  echo '[ERROR] Flux CLI is not installed.' >&2
  exit 2
}

kubectl get nodes >/dev/null
flux check --pre

echo "[INFO] Bootstrapping Flux ${FLUX_VERSION}."
echo "[INFO] Repository: ${GITHUB_USER}/${GITHUB_REPO}"
echo "[INFO] Cluster path: ${FLUX_CLUSTER_PATH}"
echo '[INFO] Git authentication: read-only SSH deploy key.'

flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository="$GITHUB_REPO" \
  --branch="$GITHUB_BRANCH" \
  --path="$FLUX_CLUSTER_PATH" \
  --personal \
  --private=false \
  --token-auth=false \
  --read-write-key=false \
  --version="$FLUX_VERSION"

flux check
flux get all --all-namespaces

echo '[PASS] Flux bootstrap completed.'
echo '[INFO] Pull the Flux-generated commit into the local repository.'
