{
  myvars,
  mylib,
  ...
}:
#############################################################
#
#  Kana — NixOS VM на Proxmox/KubeVirt
#
#############################################################
let
  hostName = "kana"; # имя хоста

  inherit (myvars.networking) proxyGateway proxyGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
in
{
  imports = [
    ../idols-ruby/packages.nix
    ../idols-ruby/oci-containers
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
        GatewayOnLink = true; # шлюз в локальном сегменте
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # stateVersion: от какого релиза NixOS взяты дефолты для stateful данных.
  # Обычно оставляют версию первой установки.
  # Перед сменой — man configuration.nix / https://nixos.org/nixos/options.html
  system.stateVersion = "24.11"; # комментарий выше прочитан?
}
