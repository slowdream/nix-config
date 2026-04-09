{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    moonlight-qt # клиент Moonlight — стрим игр/десктопа с ПК
  ];

  # ===============================================================================
  #
  # Sunshine: свой game stream server для Moonlight (client).
  # Для стриминга игр, но подходит и для remote desktop.
  #
  # Как пользоваться:
  #  1. Настроить пользователя в Web Console: <https://localhost:47990/>):
  #  2. С другой машины подключиться через moonlight-qt
  #
  # Документация:
  #  https://docs.lizardbyte.dev/projects/sunshine/latest/index.html
  #
  # Статус сервиса
  #   systemctl --user status sunshine
  # Логи
  #   journalctl --user -u sunshine --since "2 minutes ago"
  #
  # Ссылки:
  #   https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/networking/sunshine.nix
  #
  # ===============================================================================
  services.sunshine = {
    enable = lib.mkDefault false; # по умолчанию выключено из соображений безопасности
    autoStart = true;
    capSysAdmin = true; # нужно для Wayland — убрать при Xorg
    openFirewall = true;
    settings = {
      # pc  — только localhost к web UI
      # lan — только устройства в LAN
      origin_web_ui_allowed = "pc";
      # 2 — шифрование обязательно, без шифрования отклоняется
      lan_encryption_mode = 2;
      wan_encryption_mode = 2;
    };
  };
}
