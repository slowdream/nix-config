#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

host="${1:-vm-test}"

nix run --experimental-features "nix-command flakes" github:nix-community/disko -- \
  --mode destroy,format,mount "../hosts/${host}/disko-fs.nix"

mkdir -p /mnt/nix
mount --bind /mnt/nix /nix

nixos-install --root /mnt --flake ".#${host}" --no-root-password
