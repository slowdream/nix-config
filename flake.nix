{
  description = "Конфигурация NixOS (flake)";

  ##################################################################################################################
  #
  # Хотите разобраться в Nix подробнее? Ищете понятный туториал для начинающих?
  # См. https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  outputs = inputs: import ./outputs inputs;

  # nixConfig здесь влияет только на сам flake, не на system configuration!
  # подробнее:
  #     https://nixos-and-flakes.thiscute.world/nix-store/add-binary-cache-servers
  nixConfig = {
    # substituters добавятся к default substituters при fetch пакетов
    extra-substituters = [
      "https://cache.numtide.com"
      # "https://nix-gaming.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
      # "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      # "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  # Стандартный формат flake.nix: `inputs` — зависимости flake,
  # каждый элемент `inputs` передаётся в функцию `outputs` после pull и build.
  inputs = {
    # Ссылаться на flake inputs можно по-разному; чаще всего github:owner/name/reference —
    # это GitHub repo URL + branch/commit-id/tag.

    # Официальный источник пакетов NixOS, по умолчанию ветка nixos unstable
    # Хэш коммита и статус сборок (3 job в день):
    # https://hydra.nixos.org/jobset/nixpkgs/unstable
    # обновление: nix flake update nixpkgs --override-input nixpkgs github:NixOS/nixpkgs/<commit-hash>
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";

    # nixpkgs с кастомными патчами
    nixpkgs-patched.url = "github:ryan4yin/nixpkgs/nixos-unstable-patched";
    # свежие пакеты с ветки master
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # home-manager — user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-25.11";

      # Ключевое слово `follows` во inputs — для наследования.
      # Здесь `inputs.nixpkgs` у home-manager совпадает с `inputs.nixpkgs` текущего flake,
      # чтобы не ловить проблемы из-за разных версий зависимостей nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/catppuccin/nix
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation = {
      url = "github:nix-community/preservation";
    };

    # iso/qcow2/docker/... image из nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secrets management
    agenix = {
      # зафиксировано на git commit от 18 мая 2025
      url = "github:ryantm/agenix/4835b1dc898959d8547a871ef484930675cb47f1";
      # заменено type-safe reimplementation для лучших сообщений об ошибках и меньше багов
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # git hooks: форматировать nix перед commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nuenv = {
      url = "github:DeterminateSystems/nuenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty/tip"; # Latest Continuous Release
    };

    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      # Helix со steel как plugin system
      # https://github.com/helix-editor/helix/pull/8675
      url = "github:mattwparas/helix/steel-event-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding agents
    llm-agents.url = "github:numtide/llm-agents.nix";

    # -------------- Gaming ---------------------

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/release-25.11";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    ########################  Some non-flake repositories  #########################################

    nu_scripts = {
      url = "github:ryan4yin/nu_scripts";
      flake = false;
    };

    ########################  My own repositories  #########################################

    # приватные secrets — приватный репозиторий; у себя замените на свой
    # ssh: аутентификация через ssh-agent/ssh-key, shallow clone для скорости
    mysecrets = {
      url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1";
      flake = false;
    };

    # обои
    wallpapers = {
      url = "github:ryan4yin/wallpapers";
      flake = false;
    };

    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
