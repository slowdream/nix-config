{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/guix/default.nix
  services.guix = {
    enable = true;
    # Каталог store, из которого сервис Guix отдаёт/куда пишет.
    # Примечание: кэшированные сборки обычно предполагаются в `/gnu/store`.
    storeDir = "/gnu/store";
    # State directory: профили пользователей, кэш и state-файлы сервиса Guix.
    stateDir = "/var";
    gc = {
      enable = true;
      # https://guix.gnu.org/en/manual/en/html_node/Invoking-guix-gc.html
      extraArgs = [
        "--delete-generations=1m"
        "--free-space=10G"
        "--optimize"
      ];
    };
  };
}
