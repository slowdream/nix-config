# Не править вручную: сгенерировано `nixos-generate-config`, может перезаписаться.
# Меняйте /etc/nixos/configuration.nix (или flake).
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelParams = [ ];

  # загрузчик EFI
  # В VM часто нет стабильного EFI NVRAM, поэтому ставим fallback
  # в /boot/EFI/BOOT/BOOTX64.EFI (removable) и не трогаем EFI variables.
  boot.loader.efi.canTouchEfiVariables = false;
  # при другой разметке — /boot или /boot/efi
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = true;

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/top-level/linux-kernels.nix
  boot.kernelPackages = pkgs.linuxPackages_6_18; # 6.19 плохо с драйвером NVIDIA

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "virtio_pci"
    "virtio_blk"
    "sr_mod"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # KVM
  boot.extraModprobeConfig = "options kvm_intel nested=1"; # nested на Intel
  boot.extraModulePackages = [ ];
  # чистый /tmp при загрузке
  boot.tmp.cleanOnBoot = true;

  # binfmt: aarch64-linux для кросс-компиляции
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
  # Статические эмуляторы подгружаются ядром — не нужны в chroot (podman и т.д.)
  boot.binfmt.preferStaticEmulators = true; # для podman

  # ФС для съёмных носителей
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  # LUKS в initrd; /, /boot, /btr_pool, /nix, /gnu, /persistent, /snapshots, /tmp, /swap — в disko-fs.nix

  # DHCP на интерфейсах; со systemd-networkd лучше явно per-interface useDHCP
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance"; # ondemand / powersave / performance
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
