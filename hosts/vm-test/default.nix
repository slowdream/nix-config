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
  ];

  # zram жрёт RAM под сжатие — при модели ~RAM возможен deadlock
  zramSwap.enable = lib.mkForce false;

  services.sunshine.enable = false;
  services.tuned.ppdSettings.main.default = lib.mkForce "performance";

  networking = {
    inherit hostName;
    # Включаем NetworkManager для автоматического поднятия сети по DHCP
    networkmanager.enable = lib.mkForce true;
  };

  # Отключаем systemd-networkd со статическими IP для виртуалки
  networking.useNetworkd = lib.mkForce false;
  systemd.network.enable = lib.mkForce false;

  systemd.user.services.niri.serviceConfig.Environment = [
    "WLR_RENDERER=pixman"
    "WLR_NO_HARDWARE_CURSORS=1"
    "LIBGL_ALWAYS_SOFTWARE=1"
  ];

  # stateVersion — см. man configuration.nix
  system.stateVersion = "25.11"; # комментарий выше прочитан?
}
