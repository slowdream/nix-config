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

  boot.loader = {
    # при другой разметке диска — /boot или /boot/efi
    efi.efiSysMountPoint = "/boot/";
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  # чистый /tmp при каждой загрузке
  boot.tmp.cleanOnBoot = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [
    "kvm-amd"
    "vfio-pci"
  ];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # nested KVM на AMD

  # ФС для съёмных дисков
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "ntfs"
    "fat"
    "vfat"
  ];

  # DHCP на ethernet/wifi: ок со scripted networking;
  # с systemd-networkd лучше явно `networking.interfaces.<iface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
