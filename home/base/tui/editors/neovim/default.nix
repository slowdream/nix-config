{
  config,
  lib,
  pkgs,
  ...
}:
###############################################################################
#
#  Конфиг AstroNvim и зависимости (LSP, formatter и т.д.)
#
###############################################################################
let
  shellAliases = {
    v = "nvim";
    vdiff = "nvim -d";
  };
  # путь к каталогу nvim
  # для symlink нужен git clone этого репо в home
  configPath = "${config.home.homeDirectory}/nix-config/home/base/tui/editors/neovim/nvim";
in
{
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink configPath;
  # catppuccin выключить — конфликт с не-nix конфигом
  catppuccin.nvim.enable = false;

  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    # defaultEditor = true; # EDITOR на уровне системы
    viAlias = true;
    vimAlias = true;

    # Переменные для сборки и запуска бинарей
    # через внешние менеджеры вроде mason.nvim.
    #
    # LD_LIBRARY_PATH нужен для non-FHS бинарей из mason.nvim.
    # Задаёт nix-ld, здесь дублировать не нужно.
    extraWrapperArgs = with pkgs; [
      # LIBRARY_PATH — поиск каталогов со статикой/шаренными либами для линковки
      "--suffix"
      "LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        stdenv.cc.cc
        zlib
      ]}"

      # PKG_CONFIG_PATH — поиск .pc для pkg-config перед сборкой
      "--suffix"
      "PKG_CONFIG_PATH"
      ":"
      "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
        stdenv.cc.cc
        zlib
      ]}"
    ];

    # Сейчас пакетный менеджер — lazy.nvim, это закомментировано.
    #
    # NOTE: astronvim эти плагины по умолчанию не подхватит!
    # Собирать локально или тянуть FHS-бинари через Nix,
    # в lazy.nvim указывать `dir` на путь в nix store —
    # тогда на NixOS заведётся.
    plugins = with pkgs.vimPlugins; [
      # плагины: https://search.nixos.org/packages
      telescope-fzf-native-nvim

      # nvim-treesitter.withAllGrammars
    ];
  };
}
