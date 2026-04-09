{
  disko,
  mylib,
  lib,
  ...
}:
#############################################################
#
#  Akane — NixOS VM в UTM на macOS
#
#############################################################
let
  hostName = "akane"; # имя хоста
in
{
  imports = (mylib.scanPaths ./.) ++ [
    disko.nixosModules.default
  ];

  # ФС для съёмных носителей
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"

    # обмен файлами хост ↔ гость
    "virtiofs"
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "usbhid"
    "usb_storage"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # systemd-boot EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  networking = {
    inherit hostName;

    networkmanager.enable = true;
  };

  # stateVersion — см. man configuration.nix / nixos options
  system.stateVersion = "26.05"; # комментарий выше прочитан?
}
