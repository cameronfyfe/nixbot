#!/usr/bin/env bash
set -euo pipefail

nix_file="${1:-/etc/nixos/pkgs/codex.nix}"

if [[ ! -f "$nix_file" ]]; then
  echo "codex nix file not found: $nix_file" >&2
  exit 1
fi

latest_tag=$(curl -fsSL https://api.github.com/repos/openai/codex/releases/latest \
  | awk -F'"' '/"tag_name"/ {print $4; exit}')

if [[ -z "$latest_tag" ]]; then
  echo "Failed to determine latest Codex tag" >&2
  exit 1
fi

if [[ "$latest_tag" != rust-v* ]]; then
  echo "Unexpected tag format: $latest_tag" >&2
  exit 1
fi

version="${latest_tag#rust-v}"
base_url="https://github.com/openai/codex/releases/download/${latest_tag}"

x86_url="${base_url}/codex-x86_64-unknown-linux-musl.tar.gz"
arm_url="${base_url}/codex-aarch64-unknown-linux-musl.tar.gz"

prefetch_hash() {
  local url="$1"
  nix --extra-experimental-features "nix-command" store prefetch-file --json "$url" \
    | awk -F'"' '/"hash"/ {print $4; exit}'
}

x86_hash=$(prefetch_hash "$x86_url")
arm_hash=$(prefetch_hash "$arm_url")

if [[ -z "$x86_hash" || -z "$arm_hash" ]]; then
  echo "Failed to prefetch one or more Codex archives" >&2
  exit 1
fi

tmp_file=$(mktemp)
cp "$nix_file" "$tmp_file"

perl -0pi -e "s/version = \"[^\"]+\";/version = \"${version}\";/" "$tmp_file"
perl -0pi -e "s|codex-x86_64-unknown-linux-musl.tar.gz\";\n\s*hash = \"[^\"]+\";|codex-x86_64-unknown-linux-musl.tar.gz\";\n      hash = \"${x86_hash}\";|" "$tmp_file"
perl -0pi -e "s|codex-aarch64-unknown-linux-musl.tar.gz\";\n\s*hash = \"[^\"]+\";|codex-aarch64-unknown-linux-musl.tar.gz\";\n      hash = \"${arm_hash}\";|" "$tmp_file"

mv "$tmp_file" "$nix_file"

cat <<SUMMARY
Updated $nix_file
- version: $version
- x86_64 hash: $x86_hash
- aarch64 hash: $arm_hash
SUMMARY
