{
  pkgs,
  ghostty,
  ...
}:
###########################################################
#
# Конфигурация Ghostty
#
###########################################################
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty; # пакет из nixpkgs (stable)
    # package = ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default; # последняя из flake input
    enableBashIntegration = false;
    installBatSyntax = false;
    # installVimSyntax = true;
    settings = {
      font-family = "Maple Mono NF CN";
      font-size = 13;

      background-opacity = 0.93;
      scrollback-limit = 20000;

      # https://ghostty.org/docs/config/reference#command
      #  Обход проблем:
      #    1. https://github.com/ryan4yin/nix-config/issues/26
      #    2. https://github.com/ryan4yin/nix-config/issues/8
      #  Запуск nushell в login mode через `bash`
      command = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
    };
  };
}
