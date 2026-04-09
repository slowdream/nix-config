{
  pkgs,
  pkgs-x64,
  ...
}:
# медиа: звук и видео
{
  home.packages = with pkgs; [
    # звук
    pavucontrol
    playerctl
    pulsemixer
    imv # просмотр картинок

    # видео / Vulkan / VA
    libva-utils
    vdpauinfo
    vulkan-tools
    mesa-demos
    nvitop
    (pkgs-x64.zoom-us)
  ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  services = {
    playerctld.enable = true;
  };
}
