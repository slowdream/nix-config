{ pkgs, ... }:
{
  # только Linux, на Darwin нет
  home.packages = with pkgs; [
    # прочее
    libnotify
    wireguard-tools # WireGuard вручную, wg-quick

    virt-viewer # VNC к VM (kubevirt)
  ];

  # USB-диски
  services = {
    udiskie.enable = true;
    # syncthing.enable = true;
  };
}
