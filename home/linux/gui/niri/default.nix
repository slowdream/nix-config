{
  pkgs,
  config,
  lib,
  ...
}@args:
let
  cfg = config.modules.desktop.niri;
in
{
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "niri compositor";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = with pkgs; [
          # Niri v25.08: X11-сокеты на диске, $DISPLAY, `xwayland-satellite` по требованию при X11-клиенте
          xwayland-satellite
        ];

        xdg.configFile =
          let
            mkSymlink = config.lib.file.mkOutOfStoreSymlink;
            confPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/niri/conf";
          in
          {
            "niri/config.kdl".source = mkSymlink "${confPath}/config.kdl";
            "niri/keybindings.kdl".source = mkSymlink "${confPath}/keybindings.kdl";
            "niri/noctalia-shell.kdl".source = mkSymlink "${confPath}/noctalia-shell.kdl";
            "niri/spawn-at-startup.kdl".source = mkSymlink "${confPath}/spawn-at-startup.kdl";
            "niri/windowrules.kdl".source = mkSymlink "${confPath}/windowrules.kdl";
          };

        systemd.user.services.niri-flake-polkit = {
          Unit = {
            Description = "PolicyKit Authentication Agent provided by niri-flake";
            After = [
              "graphical-session.target"
            ];
            Wants = [ "graphical-session-pre.target" ];
          };
          Install.WantedBy = [ "niri.service" ];
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        # greetd вызывает этот скрипт для Wayland-сессии при загрузке;
        # без vendor lock можно сменить compositor, не трогая greetd в модуле NixOS
        home.file.".wayland-session" = {
          source = pkgs.writeScript "init-session" ''
            # остановить предыдущую сессию niri
            systemctl --user is-active niri.service && systemctl --user stop niri.service
            # новая сессия
            /run/current-system/sw/bin/niri-session
          '';
          executable = true;
        };
      }
    ]
  );

}
