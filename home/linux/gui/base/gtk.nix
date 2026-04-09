{
  pkgs,
  config,
  ...
}:
{
  # Если курсор, иконки или тема окон не подхватываются,
  # задайте их через home.pointerCursor и gtk.theme —
  # включится совместимость, темы грузятся стабильнее.

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # DPI для 4K
  xresources.properties = {
    # DPI шрифтов Xorg
    "Xft.dpi" = 150;
    # или общий DPI
    "*.dpi" = 150;
  };

  # GTK: генерит
  #   1. ~/.gtkrc-2.0
  #   2. ~/.config/gtk-3.0/settings.ini
  #   3. ~/.config/gtk-4.0/settings.ini
  gtk = {
    enable = true;

    font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
      size = 11;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };
}
