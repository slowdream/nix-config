{
  pkgs,
  config,
  lib,
  myvars,
  ...
}:
with lib;
let
  cfgWayland = config.modules.desktop.wayland;
in
{
  imports = [
    ./base
    ../base

    ./desktop
  ];

  options.modules.desktop = {
    wayland = {
      enable = mkEnableOption "Wayland Display Server";
    };
  };

  config = mkMerge [
    (mkIf cfgWayland.enable {
      ####################################################################
      #  Конфигурация NixOS для оконного менеджера на базе Wayland
      ####################################################################
      services = {
        xserver.enable = false; # отключить Xorg server
        # https://wiki.archlinux.org/title/Greetd
        greetd = {
          enable = true;
          settings = {
            default_session = {
              # Wayland Desktop Manager установлен только для пользователя ryan через home-manager!
              user = myvars.username;
              # .wayland-session — скрипт, генерируемый home-manager; ссылается на текущий wayland compositor (sway/hyprland и др.).
              # С таким vendor-neutral скриптом можно сменить compositor без правки конфига greetd здесь.
              command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd $HOME/.wayland-session"; # старт wayland session через TUI login manager
              # command = "$HOME/.wayland-session"; # напрямую запустить wayland session без login manager
            };
          };
        };
      };

      # fix https://github.com/ryan4yin/nix-config/issues/10
      security.pam.services.swaylock = { };
    })
  ];
}
