{
  config,
  pkgs,
  lib,
  mylib,
  ...
}:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
  repo = mylib.relativeToRoot ".";
  niriConf = mylib.relativeToRoot "home/linux/gui/niri/conf";
  reorderScript = mylib.relativeToRoot "home/linux/gui/niri/reorder-workspaces.sh";

  niriConfigText =
    builtins.replaceStrings
      [ ''spawn-sh-at-startup "bash ~/nix-config/home/linux/gui/niri/reorder-workspaces.sh"'' ]
      [ ''spawn-sh-at-startup "bash ${reorderScript}"'' ]
      (builtins.readFile (niriConf + "/config.kdl"));
in
{
  imports = [ ../../linux/gui.nix ];

  programs.ssh.matchBlocks."github.com".identityFile = "${config.home.homeDirectory}/.ssh/vm-test";

  modules.desktop.gaming.enable = true;
  modules.desktop.niri.enable = true;
  # modules.desktop.nvidia.enable = true;

  # Только для VM: не завязываемся на ~/nix-config (out-of-store), чтобы niri стартовал стабильно.
  xdg.configFile."niri/config.kdl" = lib.mkForce { text = niriConfigText; };
  xdg.configFile."niri/keybindings.kdl" = lib.mkForce { source = niriConf + "/keybindings.kdl"; };
  xdg.configFile."niri/windowrules.kdl" = lib.mkForce { source = niriConf + "/windowrules.kdl"; };
  xdg.configFile."niri/noctalia-shell.kdl" = lib.mkForce { source = niriConf + "/noctalia-shell.kdl"; };
  xdg.configFile."niri/niri-hardware.kdl" = lib.mkForce { source = repo + "/hosts/vm-test/niri-hardware.kdl"; };

  # VirtualBox: Vulkan часто ломает запуск композитора → форсим OpenGL backend.
  # Эти переменные поймают и systemd user unit niri.service, и запуск через .wayland-session.
  systemd.user.services.niri.Service.Environment = lib.mkForce [
    "WGPU_BACKEND=gl"
    "RUST_BACKTRACE=1"
  ];

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
