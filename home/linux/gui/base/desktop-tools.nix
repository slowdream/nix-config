{ mylib, pkgs, ... }:
{
  # wayland
  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # ozone-браузеры и Electron на Wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # Firefox на Wayland
    "MOZ_WEBRENDER" = "1";
    # нативный Wayland у большинства Electron
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
    # прочее
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "QT_QPA_PLATFORM" = "wayland";
    "SDL_VIDEODRIVER" = "wayland";
    "GDK_BACKEND" = "wayland";
    "XDG_SESSION_TYPE" = "wayland";
  };

  home.packages = with pkgs; [
    swaybg # обои
    wl-clipboard # буфер обмена
    hyprpicker # пипетка
    brightnessctl
    # звук
    alsa-utils # amixer, alsamixer, …
    networkmanagerapplet # nm-connection-editor
    # скриншот / запись
    flameshot
    hyprshot
    wf-recorder
  ];

  # блокировка экрана
  programs.swaylock.enable = true;

  # меню выхода
  programs.wlogout.enable = true;
}
