{
  config,
  pkgs,
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
  xdg.configFile."niri/config.kdl".text = niriConfigText;
  xdg.configFile."niri/keybindings.kdl".source = niriConf + "/keybindings.kdl";
  xdg.configFile."niri/windowrules.kdl".source = niriConf + "/windowrules.kdl";
  xdg.configFile."niri/noctalia-shell.kdl".source = niriConf + "/noctalia-shell.kdl";
  xdg.configFile."niri/niri-hardware.kdl".source = repo + "/hosts/vm-test/niri-hardware.kdl";
}
