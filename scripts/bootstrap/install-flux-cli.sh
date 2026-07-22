#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
# shellcheck disable=SC1091
source "$repo_root/versions.env"

version_no_v=${FLUX_VERSION#v}
archive="flux_${version_no_v}_linux_amd64.tar.gz"
expected_sha='4092b367fd060097976fb7261601f79420ecf7266328417dfd8dfee27de0e6a3'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/${archive}" -o "$tmp/$archive"
echo "$expected_sha  $tmp/$archive" | sha256sum --check

tar -xzf "$tmp/$archive" -C "$tmp" flux
sudo install -m 0755 "$tmp/flux" /usr/local/bin/flux
flux version --client
flux check --pre
