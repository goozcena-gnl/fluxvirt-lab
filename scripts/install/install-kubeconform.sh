#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
# shellcheck disable=SC1091
source "$repo_root/versions.env"
: "${KUBECONFORM_LINUX_AMD64_SHA256:?KUBECONFORM_LINUX_AMD64_SHA256 is missing from versions.env.}"

install_dir=/usr/local/bin

while (($# > 0)); do
  case "$1" in
    --install-dir)
      install_dir=${2:?missing argument for --install-dir}
      shift 2
      ;;
    *)
      echo "Usage: $0 [--install-dir DIR]" >&2
      exit 2
      ;;
  esac
done

archive="kubeconform-linux-amd64.tar.gz"
release_url="https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl \
  --fail \
  --location \
  --silent \
  --show-error \
  --output "$tmp/$archive" \
  "${release_url}/${archive}"

curl \
  --fail \
  --location \
  --silent \
  --show-error \
  --output "$tmp/CHECKSUMS" \
  "${release_url}/CHECKSUMS"

checksum_line=$(grep " ${archive}$" "$tmp/CHECKSUMS" || true)

if [[ -z "$checksum_line" ]]; then
  echo "[ERROR] Missing checksum entry for ${archive} in upstream CHECKSUMS." >&2
  exit 1
fi

upstream_checksum=$(awk '{print $1}' <<<"$checksum_line")

if [[ "$upstream_checksum" != "$KUBECONFORM_LINUX_AMD64_SHA256" ]]; then
  echo "[ERROR] Upstream CHECKSUMS entry for ${archive} does not match the pinned official checksum." >&2
  exit 1
fi

printf '%s  %s\n' \
  "$KUBECONFORM_LINUX_AMD64_SHA256" \
  "$tmp/$archive" |
  sha256sum --check -

mapfile -t binary_members < <(
  tar -tzf "$tmp/$archive" |
    awk '/(^|\/)kubeconform$/ {print}'
)

if (( ${#binary_members[@]} != 1 )); then
  echo "[ERROR] Expected exactly one kubeconform archive member in ${archive}." >&2
  exit 1
fi

binary_member=${binary_members[0]}

case "$binary_member" in
  ""|/*|../*|*/../*|*/..|..)
    echo "[ERROR] Refusing unsafe kubeconform archive member path: ${binary_member}" >&2
    exit 1
    ;;
esac

tar -xzf "$tmp/$archive" -C "$tmp" "$binary_member"
binary_path="$tmp/$binary_member"

if [[ ! -f "$binary_path" ]]; then
  echo "[ERROR] kubeconform binary not found after extracting ${archive}." >&2
  exit 1
fi

if mkdir -p "$install_dir" 2>/dev/null && [[ -w "$install_dir" ]]; then
  install --mode=0755 "$binary_path" "$install_dir/kubeconform"
else
  sudo mkdir -p "$install_dir"
  sudo install --mode=0755 "$binary_path" "$install_dir/kubeconform"
fi

"$install_dir/kubeconform" -v
