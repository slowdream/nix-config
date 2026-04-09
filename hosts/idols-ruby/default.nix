{
  myvars,
  mylib,
  ...
}:
#############################################################
#
#  Ruby — NixOS VM на Proxmox/KubeVirt
#
#############################################################
let
  hostName = "ruby"; # имя хоста

  inherit (myvars.networking) proxyGateway proxyGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
in
{
  imports = [
    ./packages.nix
    ./oci-containers
  ];

  # binfmt: эмуляция aarch64-linux для кросс-компиляции
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
  # Ядро подгружает статические эмуляторы при регистрации binfmt —
  # не нужно класть их в chroot (podman и т.п.).
  boot.binfmt.preferStaticEmulators = true; # для podman

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

  # stateVersion — см. комментарий в конфиге Kana / man configuration.nix
  system.stateVersion = "24.11"; # комментарий выше прочитан?
}
