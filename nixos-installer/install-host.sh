#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

# Если скрипт запущен из-под /mnt, то при wipe disko перемонтирует /mnt и путь исчезнет.
# Поэтому автоматически копируем nixos-installer в /tmp и перезапускаемся оттуда.
case "$script_dir" in
  /mnt/*)
    tmp_dir="/tmp/nixos-installer"
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cp -a "$script_dir"/. "$tmp_dir"/
    exec "$tmp_dir/install-host.sh" "$@"
    ;;
esac

cd "$script_dir"

host="${1:-vm-test}"
default_user="$(awk -F'"' '/^[[:space:]]*username[[:space:]]*=[[:space:]]*"/{print $2; exit}' ../vars/default.nix 2>/dev/null || true)"
user="${default_user:-ryan}"

nix run --experimental-features "nix-command flakes" github:nix-community/disko -- \
  --mode destroy,format,mount "../hosts/${host}/disko-fs.nix" --yes-wipe-all-disks

# Включаем swap, который создал disko, чтобы инсталлеру хватило памяти (RAM)
if [ -f /mnt/swap/swapfile ]; then
  swapon /mnt/swap/swapfile || true
fi

nixos-install --root /mnt --flake ".#${host}" --no-root-password

# Если репозиторий уже склонирован во время установки — положить его в систему,
# чтобы после первого входа не надо было заново `git clone`.
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dest="/mnt/home/${user}/nix-config"

mkdir -p "/mnt/home/${user}"
rm -rf "$dest"
cp -a "$repo_root" "$dest"

# Выставить владельца по данным установленной системы (если пользователь уже создан).
if [ -f /mnt/etc/passwd ]; then
  ug="$(awk -F: -v u="$user" '$1==u{print $3":"$4}' /mnt/etc/passwd || true)"
  if [ -n "${ug:-}" ]; then
    chown -R "$ug" "$dest" || true
  fi
fi
