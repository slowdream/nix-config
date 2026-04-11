{
  config,
  pkgs,
  lib,
  ...
}:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ ../../linux/gui.nix ];

  programs.ssh.matchBlocks."github.com".identityFile = "${config.home.homeDirectory}/.ssh/vm-test";

  modules.desktop.gaming.enable = true;
  modules.desktop.niri.enable = true;
  # modules.desktop.nvidia.enable = true;

  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/vm-test/niri-hardware.kdl";

  # VirtualBox: Vulkan часто ломает запуск композитора → форсим OpenGL backend.
  systemd.user.services.niri.Service.Environment = [
    "WGPU_BACKEND=gl"
    "RUST_BACKTRACE=1"
  ];

  # Переопределяем скрипт запуска, чтобы он тоже использовал OpenGL
  home.file.".wayland-session" = lib.mkForce {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      export WGPU_BACKEND=gl
      export RUST_BACKTRACE=1

      systemctl --user is-active niri.service && systemctl --user stop niri.service || true
      exec /run/current-system/sw/bin/niri-session
    '';
    executable = true;
  };
}
