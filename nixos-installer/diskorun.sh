#!/usr/bin/env bash
set -euo pipefail

# Запускать из `nix-config/nixos-installer` (как в README).
#
# Использование:
#   ./vm-test-disko.sh vm-test
#   ./vm-test-disko.sh          # по умолчанию vm-test
host="${1:-vm-test}"

exec nix run --experimental-features "nix-command flakes" github:nix-community/disko -- --mode destroy,format,mount "../hosts/${host}/disko-fs.nix"

