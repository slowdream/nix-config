{
  lib,
  mylib,
  myvars,
  pkgs,
  disko,
  ...
}:
#############################################################
#
#  Aquamarine — NixOS VM на Proxmox/KubeVirt
#
#############################################################
let
  hostName = "aquamarine"; # имя хоста

  inherit (myvars.networking) proxyGateway proxyGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
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
  ];

  # Лимит памяти под zram swap (% от RAM). По умолчанию ~половина RAM. Смотреть `zramctl`.
  # Не то же самое, сколько реально займёт zram.
  zramSwap.memoryPercent = lib.mkForce 100;

  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # nested KVM на AMD

  networking = {
    inherit hostName;

    # networkd вместо NetworkManager
    networkmanager.enable = false;
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [ iface ];
    networkConfig = {
      Address = [ ipv4WithMask ];
      # DNS = nameservers;
      DNS = [ proxyGateway ];
      DHCP = "ipv6"; # только DHCPv6 для GUA
      IPv6AcceptRA = true; # SLAAC
      LinkLocalAddressing = "ipv6";
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = proxyGateway;
      }
      {
        Destination = "::/0";
        Gateway = proxyGateway6;
        GatewayOnLink = true; # шлюз на линке
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # stateVersion — см. man configuration.nix
  system.stateVersion = "24.11"; # комментарий выше прочитан?
}
