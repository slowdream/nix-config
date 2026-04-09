{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.nvidia;
in
{
  options.modules.desktop.nvidia = {
    enable = mkEnableOption "whether nvidia GPU is used";
  };

  config = mkIf (cfg.enable && cfg.enable) {
    home.sessionVariables = {
      # Hyprland + NVIDIA GPU, см. https://wiki.hyprland.org/Nvidia/
      "LIBVA_DRIVER_NAME" = "nvidia";
      "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
      # VA-API, аппаратное декодирование видео
      "NVD_BACKEND" = "direct";

      "GBM_BACKEND" = "nvidia-drm";
    };
  };
}
