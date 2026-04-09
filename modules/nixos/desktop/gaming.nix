{
  pkgs,
  pkgs-x64,
  nix-gaming,
  aagl,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.gaming;
in
{
  imports = [
    nix-gaming.nixosModules.pipewireLowLatency
    nix-gaming.nixosModules.platformOptimizations

    # запуск anime games на Linux
    aagl.nixosModules.default
  ];

  options.modules.desktop = {
    gaming = {
      enable = mkEnableOption "Install Game Suite(steam, lutris, etc)";
    };
  };

  config = mkIf cfg.enable {
    # ==========================================================================
    # Gaming на Linux
    #
    #   <https://www.protondb.com/> — что где и как работает.
    #   Руководство для начинающих: <https://www.reddit.com/r/linux_gaming/wiki/faq/>
    # ==========================================================================

    # Игры из Steam на NixOS обычно работают без доп. настройки.
    # https://github.com/NixOS/nixpkgs/blob/master/doc/packages/steam.section.md
    programs.steam = {
      # Пути, которые лучше держать persistent:
      #   ~/.local/share/Steam — дефолтная установка Steam
      #   ~/.local/share/Steam/steamapps/common — дефолтная установка игр
      #   ~/.steam/root        — symlink на ~/.local/share/Steam
      #   ~/.steam             — symlinks и user info
      enable = true;
      package = pkgs-x64.steam;
      # https://github.com/ValveSoftware/gamescope
      # Запуск Steam session через GameScope из display-manager;
      # правит resolution upscaling и растянутые aspect ratio
      gamescopeSession.enable = true;
      # https://github.com/Winetricks/winetricks
      # Включить protontricks — обёртку для Winetricks для игр на Proton.
      protontricks.enable = true;
      # Загружать extest в Steam: перевод X11 input events в uinput (например Steam Input на Wayland).
      extest.enable = true;
      fontPackages = [
        pkgs.wqy_zenhei # нужен Steam для китайского интерфейса
      ];
    };

    # см. https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    services.pipewire.lowLatency.enable = true;
    programs.steam.platformOptimizations.enable = true;

    # Оптимизация производительности Linux по требованию
    # https://github.com/FeralInteractive/GameMode
    # https://wiki.archlinux.org/title/Gamemode
    #
    # Использование:
    #   1. Для игр/лаунчеров с интеграцией GameMode:
    #      https://github.com/FeralInteractive/GameMode#apps-with-gamemode-integration
    #      достаточно запустить игру — GameMode включится сам.
    programs.gamemode.enable = true;

    # запуск anime games на Linux
    # https://github.com/an-anime-team/
    networking.mihoyo-telemetry.block = true;
    environment.systemPackages = with aagl.packages."x86_64-linux"; [
      anime-game-launcher # Genshin: Impact
      honkers-railway-launcher # Honkai: Star Rail
      sleepy-launcher # Zenless Zon Zero
    ];
  };
}
