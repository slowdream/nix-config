# XDG — Cross-Desktop Group (X здесь = cross).
# Спеки freedesktop.org для единообразия десктопов и GUI на Unix-подобных системах:
#   https://www.freedesktop.org/wiki/Specifications/
{
  mylib,
  config,
  pkgs,
  ...
}:
{
  imports = mylib.scanPaths ./.;

  home.packages = with pkgs; [
    xdg-utils # `xdg-mime`, `xdg-open` и т.д.
    xdg-user-dirs
  ];

  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}
