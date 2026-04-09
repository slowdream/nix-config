{ lib, pkgs, ... }:
{
  xdg.terminal-exec = {
    enable = true;
    package = pkgs.xdg-terminal-exec;
    settings =
      let
        my_terminal_desktop = [
          # Примечание: эти пакеты добавлены на уровне пользователя
          "Alacritty.desktop"
          "kitty.desktop"
          "foot.desktop"
          "com.mitchellh.ghostty.desktop"
        ];
      in
      {
        GNOME = my_terminal_desktop ++ [
          "com.raggesilver.BlackBox.desktop"
          "org.gnome.Terminal.desktop"
        ];
        niri = my_terminal_desktop;
        default = my_terminal_desktop;
      };
  };

  xdg = {
    autostart.enable = lib.mkDefault true;
    menus.enable = lib.mkDefault true;
    mime.enable = lib.mkDefault true;
    icons.enable = lib.mkDefault true;
  };

  xdg.portal = {
    enable = true;

    config = {
      common = {
        # xdg-desktop-portal-gtk для всех portal interface...
        default = [
          "gtk"
          "gnome"
        ];
      };
    };

    # Выставляет NIXOS_XDG_OPEN_USE_PORTAL=1
    # xdg-open идёт через portal — меньше багов с открытием из FHS env и неожиданными env из wrappers.
    # xdg-open используют почти все программы для неизвестных file/uri;
    # например alacritty по умолчанию через xdg-open; в vscode — «External Uri Openers».
    xdgOpenUsePortal = true;

    # ls /run/current-system/sw/share/xdg-desktop-portal/portals/
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # file picker / OpenURI
      xdg-desktop-portal-gnome # screensharing
    ];
  };
}
