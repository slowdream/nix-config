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
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
    "nfs" # нужно для longhorn
  ];

  boot.kernelModules = [
    "kvm-amd"
    "vfio-pci"
  ];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # для CPU AMD

  boot.kernel.sysctl = {
    # --- filesystem --- #
    # Поднять лимиты, чтобы не упираться в лимит inotify watches
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;

    # --- network --- #
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.core.somaxconn" = 32768;

    # ----- IPv4 ----- #
    "net.ipv4.ip_forward" = 1; # включить forwarding
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.neigh.default.gc_thresh1" = 4096;
    "net.ipv4.neigh.default.gc_thresh2" = 6144;
    "net.ipv4.neigh.default.gc_thresh3" = 8192;
    "net.ipv4.neigh.default.gc_interval" = 60;
    "net.ipv4.neigh.default.gc_stale_time" = 120;
    # ----- IPv6 ----- #
    "net.ipv6.conf.all.forwarding" = 1; # включить forwarding

    # --- memory --- #
    "vm.swappiness" = 0; # не свопить, пока это не критично необходимо
  };

  environment.systemPackages = with pkgs; [
    # Проверка поддержки виртуализации на железе:
    #   virt-host-validate qemu
    libvirt
    kubevirt # virtctl

    # для ovs-cni в kubernetes
    # https://github.com/k8snetworkplumbingwg/multus-cni
    multus-cni
  ];

  # Обходной путь для longhorn на NixOS
  # https://github.com/longhorn/longhorn/issues/2166
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  # Longhorn использует open-iscsi для блочных устройств
  services.openiscsi = {
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${hostName}";
    enable = true;
  };

  networking = {
    inherit hostName;

    # вместо этого networkd
    networkmanager.enable = false;
    useDHCP = false;
  };
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Open vSwitch как unit systemd
  # Нужно для ovs-cni в kubernetes
  virtualisation.vswitch = {
    enable = true;
    # сбрасывать БД Open vSwitch к дефолту при каждом старте ovsdb.service
    resetOnStart = false;
  };
  networking.vswitches = {
    # https://github.com/k8snetworkplumbingwg/ovs-cni/blob/main/docs/demo.md
    ovsbr1 = {
      # Подключить интерфейсы к OVS bridge
      # Этим интерфейсом сам хост пользоваться не должен!
      interfaces.${iface} = { };
    };
  };

  # systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";

  # Адрес хоста задаём на интерфейсе OVS bridge, а не на физическом NIC!
  systemd.network.networks = {
    "10-ovsbr1" = {
      matchConfig.Name = [ "ovsbr1" ];
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
    "20-${iface}" = {
      matchConfig.Name = [ iface ];
      networkConfig.LinkLocalAddressing = "no";
      # networkd этим интерфейсом не управляет —
      # им занимается Open vSwitch
      linkConfig.RequiredForOnline = "no";
    };
  };

  # Это значение задаёт релиз NixOS, от которого взяты дефолты для stateful-данных
  # (пути к файлам, версии БД и т.п.). Обычно его оставляют равным релизу первой
  # установки системы. Перед сменой прочитайте документацию опции
  # (например, man configuration.nix или https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Комментарий выше прочитали?
}
