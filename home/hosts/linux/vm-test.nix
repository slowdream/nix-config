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

  home.file.".wayland-session" = lib.mkForce {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      export WLR_RENDERER=pixman
      export WLR_NO_HARDWARE_CURSORS=1
      export LIBGL_ALWAYS_SOFTWARE=1

      systemctl --user is-active niri.service && systemctl --user stop niri.service || true
      exec /run/current-system/sw/bin/niri-session
    '';
    executable = true;
  };
}
