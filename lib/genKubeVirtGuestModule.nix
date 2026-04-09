{
  pkgs,
  hostName,
  networking,
  ...
}:
let
  inherit (networking) proxyGateway proxyGateway6 nameservers;
  inherit (networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
in
{
  # Поддерживаемые ФС — чтобы монтировать съёмные диски с этими файловыми системами
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "fat"
    "vfat"
    "exfat"
  ];

  networking = {
    inherit hostName;

    # вместо этого networkd
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
      DHCP = "ipv6"; # только DHCPv6, чтобы получить GUA
      IPv6AcceptRA = true; # Stateless IPv6 Autoconfiguration (SLAAC)
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
        GatewayOnLink = true; # шлюз на локальном линке
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # Это значение задаёт релиз NixOS, от которого взяты дефолты для stateful-данных
  # (пути к файлам, версии БД и т.п.). Обычно его оставляют равным релизу первой
  # установки системы. Перед сменой прочитайте документацию опции
  # (например, man configuration.nix или https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Комментарий выше прочитали?
}
