{ pkgs, ... }:
{
  programs.foot = {
    # foot только под Linux
    enable = pkgs.stdenv.isLinux;

    # foot можно в server mode: один процесс, много окон.
    # Wayland, VT и рендер — в сервере.
    # Новые окна — `footclient`, живёт пока открыто окно.
    #
    # Плюсы: меньше памяти и быстрее старт.
    # Минус: одно окно грузит CPU/вывод — страдают остальные; падение сервера — все окна пропадут.
    server.enable = true;

    # https://man.archlinux.org/man/foot.ini.5
    settings = {
      main = {
        term = "foot"; # или "xterm-256color" для максимальной совместимости
        font = "Maple Mono NF CN:size=13";
        dpi-aware = "no"; # масштаб через compositor/wm
        resize-keep-grid = "no"; # не менять размер окна при смене шрифта

        # Запуск nushell в login mode через `bash`
        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
