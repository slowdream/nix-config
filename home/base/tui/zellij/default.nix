{ pkgs, ... }:
let
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;
  };
  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  # catppuccin выключить — конфликт с не-nix конфигом
  catppuccin.zellij.enable = false;

  # автозапуск zellij в nushell
  programs.nushell.extraConfig = ''
    # автозапуск zellij
    # кроме emacs и уже запущенного zellij
    if (not ("ZELLIJ" in $env)) and (not ("INSIDE_EMACS" in $env)) {
      if "ZELLIJ_AUTO_ATTACH" in $env and $env.ZELLIJ_AUTO_ATTACH == "true" {
        ^zellij attach -c
      } else {
        ^zellij
      }

      # выход из shell при выходе из zellij
      $env.ZELLIJ_AUTO_EXIT = "false" # авто-выход выключен
      if "ZELLIJ_AUTO_EXIT" in $env and $env.ZELLIJ_AUTO_EXIT == "true" {
        exit
      }
    }
  '';

  # только bash/zsh, не nushell
  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;
}
