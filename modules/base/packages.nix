{ pkgs, ... }:
{
  # security: не подхватывать user config neovim — EDITOR может править критичные файлы
  environment.variables.EDITOR = "nvim --clean";

  environment.systemPackages = with pkgs; [
    # базовые утилиты
    nushell # nushell
    fastfetch
    neovim # не забудьте редактор для configuration.nix; nano ставится по умолчанию
    gnumake # Makefile
    just # runner команд вроде gmake, проще
    git # для nix flakes
    git-lfs # для huggingface models

    # мониторинг системы
    procs # современный ps
    btop

    # архивы
    zip
    xz
    zstd
    unzipNLS
    p7zip

    # текст
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep: `grep`/`egrep`/`fgrep`
    gawk # GNU awk
    gnutar
    gnused # GNU sed
    sad # search/replace как sed, с diff preview

    jq # JSON в CLI
    yq-go # yaml https://github.com/mikefarah/yq
    jc # вывод популярных CLI → JSON/YAML

    # fuzzy filter по stdin, не только имена файлов
    fzf
    # поиск файлов по имени, быстрее find
    fd
    findutils
    # поиск по содержимому, вместо grep
    (ripgrep.override { withPCRE2 = true; })

    duf # лучше df
    dust # du нагляднее
    gdu # анализ диска (du)
    ncdu # du интерактивно, TUI

    # сеть
    mtr # диагностика сети (traceroute)
    gping # ping с графиком (TUI)
    dnsutils # `dig` + `nslookup`
    ldns # вместо `dig`, команда `drill`
    doggo # DNS client
    wget
    curl
    curlie # curl в стиле httpie
    httpie
    aria2 # загрузки multi-protocol
    socat # вместо openbsd-netcat
    nmap # сеть / аудит
    ipcalc # калькулятор IPv4/v6
    iperf3 # пропускная способность
    hyperfine # бенчмарк CLI
    tcpdump # сниффер

    # передача файлов
    rsync
    croc # обмен между машинами

    # security
    libargon2
    openssl

    # прочее
    file
    which
    tree
    tealdeer # быстрый tldr
  ];
}
