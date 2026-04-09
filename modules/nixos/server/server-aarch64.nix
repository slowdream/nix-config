{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../base/btrbk.nix
    ../base/core.nix
    ../base/i18n.nix
    ../base/monitoring.nix
    ../base/nix.nix
    ../base/packages.nix
    ../base/ssh.nix
    ../base/user-group.nix

    ../../base
  ];

  # Обход: jasper помечен как broken и ломает evaluation
  environment.enableAllTerminfo = lib.mkForce false;
}
