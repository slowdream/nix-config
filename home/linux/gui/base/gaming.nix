{
  pkgs,
  pkgs-x64,
  osConfig,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.gaming;
in
{
  options.modules.desktop = {
    gaming = {
      enable = mkEnableOption "Install Game Suite(steam, lutris, etc)";
    };
  };

  config = mkIf cfg.enable {
    # ==========================================================================
    # Доп. настройки
    # Lutris: расширенные опции → System → Command prefix: `mangohud`
    # Steam: в параметрах запуска: `mangohud %command%` / `gamemoderun %command%`
    # ==========================================================================

    home.packages =
      (with pkgs; [
        # https://github.com/flightlessmango/MangoHud
        # оверлей: FPS, температура, загрузка CPU/GPU и т.д.
        mangohud

        # GUI для кастомных Proton (GE_Proton)
        # proton — Wine для игр
        protonplus
        # рантаймы для Wine
        winetricks
        # https://github.com/Open-Wine-Components/umu-launcher
        # единый лаунчер Windows-игр на Linux
        umu-launcher

        # sed для бинарников
        # некоторым играм нужен для фиксов
        bbe
      ])
      ++ (with pkgs-x64; [
        # лаунчер игр — Epic, GOG
        # (heroic.override {
        #   extraPkgs = _pkgs: [
        #     pkgs.gamescope # aarch64
        #   ];
        # })
      ]);

    # GUI-лаунчер Steam/GOG/Epic
    # https://lutris.net/games?ordering=-popularity
    programs.lutris = {
      enable = true;
      defaultWinePackage = pkgs-x64.proton-ge-bin;
      steamPackage = osConfig.programs.steam.package;
      protonPackages = [ pkgs-x64.proton-ge-bin ];
      winePackages = with pkgs-x64; [
        wineWow64Packages.full
      ];
      extraPackages = with pkgs; [
        winetricks
        gamescope
        gamemode
        mangohud
        umu-launcher
      ];
    };
  };
}
