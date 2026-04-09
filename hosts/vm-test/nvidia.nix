{
  config,
  lib,
  pkgs,
  ...
}:
{
  # ===============================================================================================
  # NVIDIA GPU
  # https://wiki.nixos.org/wiki/NVIDIA
  # https://wiki.hyprland.org/Nvidia/
  # ===============================================================================================

  boot.kernelParams = [
    # KMS для NVIDIA не включается сам — нужно для нормального Wayland
    "nvidia-drm.fbdev=1"
  ];
  services.xserver.videoDrivers = [ "nvidia" ]; # подтянет nvidia-vaapi-driver
  hardware.nvidia = {
    # open kernel module предпочтительнее проприетарного (постепенная замена)
    open = true;
    nvidiaSettings = true;

    # при необходимости зафиксировать версию драйвера под GPU
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
    # package = config.boot.kernelPackages.nvidiaPackages.production;

    # https://github.com/NixOS/nixpkgs/issues/489947
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # почти всем Wayland compositor нужен modesetting
    modesetting.enable = true;
    powerManagement.enable = true;

    dynamicBoost.enable = lib.mkForce true;
  };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics = {
    enable = true;
    # для nvidia-docker
    enable32Bit = true;
  };

  nixpkgs.overlays = [
    (_: super: {
      # ffmpeg-full = super.ffmpeg-full.override {
      #   withNvcodec = true;
      # };
    })
  ];

  services.sunshine.settings = {
    max_bitrate = 20000; # Kbps
    # NVENC
    nvenc_preset = 3; # 1 (быстро, хуже) — 7 (медленно, лучше)
    nvenc_twopass = "full_res"; # quarter_res / full_res
  };
}
