#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
# shellcheck disable=SC1091
source "$repo_root/versions.env"

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

(
  cd "$tmp"
  grep " ${archive}$" CHECKSUMS |
    sha256sum --check -
)

tar -xzf "$tmp/$archive" -C "$tmp" kubeconform

if [[ -w "$install_dir" ]]; then
  install --mode=0755 "$tmp/kubeconform" "$install_dir/kubeconform"
else
  sudo install --mode=0755 "$tmp/kubeconform" "$install_dir/kubeconform"
fi

"$install_dir/kubeconform" -v
