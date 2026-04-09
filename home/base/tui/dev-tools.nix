{
  pkgs,
  pkgs-patched,
  ...
}:
{
  #############################################################
  #
  #  Базовые настройки dev-окружения
  #
  #  Языковые пакеты сюда не класть (глобально), ставить:
  #     1. в IDE, например `programs.neovim.extraPackages`
  #     2. per-project: https://github.com/the-nix-way/dev-templates
  #
  #############################################################

  home.packages = with pkgs; [
    colmena # удалённый деплой NixOS

    tokei # строки кода, альтернатива cloc

    # БД
    # mycli
    pgcli
    mongosh
    sqlite

    # embedded
    minicom

    # AI
    python313Packages.huggingface-hub # huggingface-cli
    pkgs-patched.python313Packages.modelscope
    yt-dlp # youtube/bilibili/soundcloud/... видео и музыка

    # прочее
    devbox
    bfg-repo-cleaner # убрать большие файлы из истории git
    k6 # нагрузочное тестирование

    # задачи по программированию — учиться на практике
    exercism

    # Обрезает ветки, у которых upstream влит или исчез
    # Удобно на долгих проектах.
    git-trim
    gitleaks

    # перед использованием: `conda-install`
    # перед командой `conda`: `conda-shell`
    # conda нет на macOS
    conda
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;

      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
