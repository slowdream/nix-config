{
  lib,
  pkgs,
  blender-bin,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # творчество
      # gimp      # растровый редактор; удобнее Figma в браузере
      inkscape # векторная графика
      krita # цифровая живопись
      musescore # ноты
      # reaper # аудио
      # sonic-pi # музыка и код

      # 2d-игры
      # aseprite # пиксель-арт и спрайты

      # много места на диске — пока не ставим
      # kicad     # печатки, 3d-печать

      # Астрономия
      stellarium # небо глазами, биноклем или небольшим телескопом
      celestia # 3D-солнечная система в реальном времени
    ]
    ++ (lib.optionals pkgs.stdenv.isx86_64 [
      # https://github.com/edolstra/nix-warez/blob/master/blender/flake.nix
      blender-bin.packages.${pkgs.stdenv.hostPlatform.system}.blender_4_2 # 3d

      ldtk # 2D level editor

      # fpga
      # python313Packages.apycula # gowin fpga
      # yosys # fpga synthesis
      # nextpnr # размещение и разводка (FPGA)
      # openfpgaloader # fpga programming
      # nur-ryan4yin.packages.${pkgs.stdenv.hostPlatform.system}.gowin-eda-edu-ide # app: `gowin-env` => `gw_ide` / `gw_pack` / ...
    ]);

  programs = {
    # стриминг
    obs-studio = {
      enable = pkgs.stdenv.isx86_64;
      plugins = with pkgs.obs-studio-plugins; [
        # захват экрана
        wlrobs
        # obs-ndi
        # obs-nvfbc
        obs-teleport
        # obs-hyperion
        droidcam-obs
        obs-vkcapture
        obs-gstreamer
        input-overlay
        obs-multi-rtmp
        obs-source-clone
        obs-shaderfilter
        obs-source-record
        obs-livesplit-one
        looking-glass-obs
        obs-vintage-filter
        obs-command-source
        obs-move-transition
        obs-backgroundremoval
        # advanced-scene-switcher
        obs-pipewire-audio-capture
        obs-vaapi
        obs-3d-effect
      ];
    };
  };
}
