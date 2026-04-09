{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # nix
    #
    # команда `nom` как `nix`, но с более подробными логами
    nix-output-monitor
    hydra-check # статус сборки пакета на hydra (build farm nix)
    nix-index # индекс путей nix store
    nix-init # derivation из URL
    # https://github.com/nix-community/nix-melt
    nix-melt # TUI для flake.lock
    # https://github.com/utdemir/nix-tree
    nix-tree # TUI: граф зависимостей derivation

    # прочее
    cowsay
    gnupg
    caddy # веб-сервер с HTTPS (Let's Encrypt), замена nginx
    # быстрый поиск/линт/рефакторинг по коду в масштабе
    # языки: в основном мейнстрим (nix/nginx/yaml/toml — нет)
    ast-grep

    # остальной базовый CLI — на уровне системы
  ];

  # Современная замена ls
  # удобно в prompt bash/zsh, не в nushell
  programs.eza = {
    enable = true;
    # алиасы в nushell не включать
    enableNushellIntegration = false;
    git = true;
    icons = "auto";
  };

  # cat(1) с подсветкой и интеграцией с git
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
  };

  # нечёткий поиск в терминале
  programs.fzf.enable = true;

  # tldr на Rust
  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };
      updates = {
        auto_update = false;
        auto_update_interval_hours = 720;
      };
    };
  };

  # zoxide — умнее cd (как z / autojump).
  # Помнит частые каталоги — переход за пару нажатий.
  # Работает в основных shell.
  #
  #   z foo              # cd в лучший матч по foo
  #   z foo bar          # cd в лучший матч по foo и bar
  #   z foo /            # cd в подкаталог, начинающийся с foo
  #
  #   z ~/foo            # как обычный cd
  #   z foo/             # относительный путь
  #   z ..               # уровень вверх
  #   z -                # предыдущий каталог
  #
  #   zi foo             # интерактивный выбор (fzf)
  #
  #   z foo<SPACE><TAB>  # completions (zoxide v0.8.0+, bash 4.4+/fish/zsh)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  # Atuin: история shell в SQLite + контекст команд.
  # Опционально E2E-синхронизация между машинами через сервер Atuin.
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
