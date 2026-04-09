{
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Конфигурация Kitty
#
# Горячие клавиши Linux (на macOS `ctrl + shift` → `cmd`):
#   1. Крупнее шрифт: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Мельче шрифт: `ctrl + shift + -` | `ctrl + shift + _`
#   3. Остальное как обычно: Copy, Paste, курсор и т.д.
#
###########################################################
{
  programs.kitty = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      # на macOS другой размер шрифта
      size = 13;
    };

    # как в других эмуляторах терминала
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback"; # поиск в текущем окне
    };

    settings = {
      # без title bar и заголовка окна
      hide_window_decorations = "titlebar-and-corners";
      macos_show_window_title_in = "none";

      background_opacity = "0.93";
      macos_option_as_alt = true; # Option = Alt на macOS
      enable_audio_bell = false;
      tab_bar_edge = "top"; # вкладки сверху
      #  Обход проблем:
      #    1. https://github.com/ryan4yin/nix-config/issues/26
      #    2. https://github.com/ryan4yin/nix-config/issues/8
      #  Запуск nushell в login mode через `bash`
      shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
    };

    # только macOS
    darwinLaunchOptions = [ "--start-as=maximized" ];
  };
}
