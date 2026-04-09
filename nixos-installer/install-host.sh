#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

host="${1:-vm-test}"

nix run --experimental-features "nix-command flakes" github:nix-community/disko -- \
  --mode destroy,format,mount "../hosts/${host}/disko-fs.nix"  --yes-wipe-all-disks

# Включаем swap, который создал disko, чтобы инсталлеру хватило памяти (RAM)
if [ -f /mnt/swap/swapfile ]; then
  swapon /mnt/swap/swapfile || true
fi

nixos-install --root /mnt --flake ".#${host}" --no-root-password
