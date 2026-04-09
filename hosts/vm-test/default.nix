{
  disko,
  myvars,
  lib,
  ...
}:
#############################################################
#
#  Ai — основной ПК: NixOS, i5-13600KF, RTX 4090, игры и повседневное использование
#
#############################################################
let
  hostName = "vm-test"; # имя хоста

  inherit (myvars.networking) mainGateway mainGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv6 = myvars.networking.hostsAddr.${hostName}.ipv6 or null;
  ipv4WithMask = "${ipv4}/24";
  ipv6WithMask = if ipv6 != null then "${ipv6}/64" else "";
in
{
  imports = [
    disko.nixosModules.default
    # диски
    ./disko-fs.nix

    # снимок железа (hardware-configuration)
    ./hardware-configuration.nix
    # ./nvidia.nix
    ./vm-test

    ./preservation.nix
    ./secureboot.nix
  ];

  # zram жрёт RAM под сжатие — при модели ~RAM возможен deadlock
  zramSwap.enable = lib.mkForce false;

  services.sunshine.enable = false;
  services.tuned.ppdSettings.main.default = lib.mkForce "performance";

  networking = {
    inherit hostName;

    # systemd-networkd вместо NM
    networkmanager.enable = false; # nmcli/nmtui для Wi‑Fi при необходимости
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [ iface ];
    networkConfig = {
      Address = [
        ipv4WithMask
      ] ++ (lib.optionals (ipv6 != null) [ ipv6WithMask ]);
      DNS = nameservers;
      # DHCP = "ipv6"; # только DHCPv6 для GUA
      # IPv6AcceptRA = true; # SLAAC
      # LinkLocalAddressing = "ipv6";
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = mainGateway;
      }
    ] ++ (lib.optionals (ipv6 != null) [
      {
        Destination = "::/0";
        Gateway = mainGateway6;
        GatewayOnLink = true; # шлюз на линке
      }
    ]);
    linkConfig.RequiredForOnline = "routable";
  };

  # stateVersion — см. man configuration.nix
  system.stateVersion = "25.11"; # комментарий выше прочитан?
}
