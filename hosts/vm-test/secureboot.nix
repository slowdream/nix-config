{
  pkgs,
  lib,
  lanzaboote,
  ...
}:
{
  # Secure Boot: плата MSI
  ## 1. BIOS — [Del]
  ## 2. <Advance mode> => <Settings> => <Security> => <Secure Boot>
  ## 3. включить <Secure Boot>
  ## 4. <Secure Boot Mode> = <Custom>
  ## 5. <Key Management>
  ## 6. <Delete All Secure Boot Variables>, затем <No> у <Reboot Without Saving>
  ## 7. F10 — сохранить и перезагрузка
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [
    # отладка Secure Boot
    pkgs.sbctl
  ];

  # Lanzaboote вместо systemd-boot.
  # После установки в configuration.nix часто systemd-boot = true — принудительно выключаем.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}
