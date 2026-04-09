{ lib, ... }:
{
  boot.loader.systemd-boot = {
    # Версии в Git — не копим лишние generation в bootloader.
    configurationLimit = lib.mkDefault 10;
    # Максимальное разрешение консоли systemd-boot.
    consoleMode = lib.mkDefault "max";
  };

  boot.loader.timeout = lib.mkDefault 8; # секунд на выбор пункта загрузки
}
