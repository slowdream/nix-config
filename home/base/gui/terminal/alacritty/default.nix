{
  pkgs,
  ...
}:
###########################################################
#
# Конфигурация Alacritty
#
# Горячие клавиши Linux:
#   1. Крупнее шрифт: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Мельче шрифт: `ctrl + shift + -` | `ctrl + shift + _`
#   3. Поиск: `ctrl + shift + N`
#   4. Прочее: Copy, Paste, движение курсора и т.д.
#
# Alacritty: без вкладок и без graphic protocol.
#
###########################################################
{
  programs.alacritty = {
    enable = true;
    # https://alacritty.org/config-alacritty.html
    settings = {
      window = {
        opacity = 0.93;
        startup_mode = "Maximized"; # окно на весь экран при старте
        dynamic_title = true;
        option_as_alt = "Both";
        decorations = "None"; # без рамки и title bar
      };
      scrolling = {
        history = 10000;
      };
      font = {
        bold = {
          family = "Maple Mono NF CN";
        };
        italic = {
          family = "Maple Mono NF CN";
        };
        normal = {
          family = "Maple Mono NF CN";
        };
        bold_italic = {
          family = "Maple Mono NF CN";
        };
        size = 13;
      };
      terminal = {
        # Запуск nushell в login mode через `bash`
        shell = {
          program = "${pkgs.bash}/bin/bash";
          args = [
            "--login"
            "-c"
            "nu --login --interactive"
          ];
        };
        # Запись в system clipboard через OSC 52
        # zellij копирует в clipboard так
        osc52 = "CopyPaste";
      };
    };
  };
}
