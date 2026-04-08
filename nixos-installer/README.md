# Подготовка Nix-окружения для host: Idols - Ai

> :red_circle: **ВАЖНО**: **не деплойте этот flake напрямую на свою машину.** Пишите свою
> конфигурацию с нуля, а этот репозиторий используйте как reference.\*\*

Этот flake готовит Nix-окружение, чтобы развернуть desktop host
[hosts/idols-ai](../hosts/idols-ai/) (из основного flake) на новой машине.

## Зачем нужен этот flake

Основной flake довольно тяжёлый и медленно деплоится. Этот минимальный flake помогает:

1. Подправить и проверить `hardware-configuration.nix` и disk layout до деплоя основного flake.
2. Протестировать preservation, Secure Boot, TPM2, шифрование и т.д. на VM или на «чистой» установке.

Disk layout задаётся **декларативно** через [disko](https://github.com/nix-community/disko); ручная
разметка диска больше не нужна.

## Шаги деплоя

1. Сделайте USB-носитель с официальным NixOS ISO и загрузитесь с него.

### 1. Разметка и монтирование через disko (рекомендуется)

Layout описан в [../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix): **nvme1n1**,
ESP (450M) + LUKS + btrfs (subvolumes: @nix, @guix, @persistent, @snapshots, @tmp, @swap). Root —
tmpfs; [preservation](https://github.com/nix-community/preservation) использует `/persistent`.

```bash
git clone https://github.com/ryan4yin/nix-config.git
cd nix-config/nixos-installer

sudo su

# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
# WARNING: destroys all data on nvme1n1. Layout is mounted at /mnt by default.
nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix

# Mount only (e.g. after first format, without wiping):
# nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs.nix

# setup the automatic unlock via the tpm2 chip
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<encrypted-disk-part-path>
```

### 2. Установка NixOS

```bash
sudo su

# From nix-config/nixos-installer
nixos-install --root /mnt --flake .#ai --no-root-password
```

### 3. Перенесите данные в /persistent и перезагрузитесь

Preservation ожидает состояние в `/persistent`; скопируйте/перенесите данные туда (например, со
старого диска), затем выйдите из chroot и перезагрузитесь.

```bash
nixos-enter

# Copy/migrate into /persistent as needed (e.g. from old nvme0n1)
# At minimum for a fresh install:
#   mkdir -p /persistent/etc
#   mv /etc/machine-id /persistent/etc/
#   mv /etc/ssh /persistent/etc/
# Then exit and:
exit
umount -R /mnt
reboot
```

После перезагрузки выставьте порядок загрузки в firmware так, чтобы система грузилась с nvme1n1.
Старый диск (например, nvme0n1) можно переиспользовать под другие задачи.

### Опционально: использовать cache mirror

```bash
nixos-install --root /mnt --flake .#ai --no-root-password \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
```

## Деплой основного flake после установки

После первой загрузки:

1. **SSH key** (чтобы подтянуть приватный репозиторий секретов):

   ```bash
   ssh-keygen -t ed25519 -a 256 -C "ryan@idols-ai" -f ~/.ssh/idols_ai
   ssh-add ~/.ssh/idols_ai
   ```

2. Rekey secrets для нового host: см. [../secrets/README.md](../secrets/README.md), чтобы agenix мог
   расшифровывать секреты SSH-ключом этого хоста.

3. Задеплойте основную конфигурацию:

   ```bash
   sudo mv /etc/nixos ~/nix-config
   sudo chown -R ryan:ryan ~/nix-config
   cd ~/nix-config
   just hypr
   ```

4. **Secure Boot**: следуйте
   [lanzaboote Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
   and [hosts/idols-ai/secureboot.nix](../hosts/idols-ai/secureboot.nix).

## Смена passphrase для LUKS2

```bash
# Test current passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/device

# Change passphrase
sudo cryptsetup luksChangeKey /path/to/device

# Verify
sudo cryptsetup --verbose open --test-passphrase /path/to/device
```

## Справка: layout и ручная разметка

Layout (ESP + LUKS + btrfs, ephemeral root, preservation на `/persistent`) описан в
[../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix). Предпочитайте disko; ручная
разметка больше здесь не описывается.

Дополнительно:

- [NixOS manual installation](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning)
- [dm-crypt / Encrypting an entire system (Arch)](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [cryptsetup FAQ](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions)
