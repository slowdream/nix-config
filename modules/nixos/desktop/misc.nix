{
  lib,
  pkgs,
  ...
}:
{
  boot.loader.timeout = lib.mkForce 10; # ждать x секунд для выбора пункта загрузки

  # добавить shell пользователя в /etc/shells
  environment.shells = with pkgs; [
    bashInteractive
    nushell
  ];
  # дефолтный shell пользователя на уровне системы
  users.defaultUserShell = pkgs.bashInteractive;

  # fix для `sudo xxx` в kitty/wezterm/foot и других современных terminal emulators
  security.sudo.keepTerminfo = true;

  # Пакеты в system profile. Поиск:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnumake
    wl-clipboard
  ];

  services = {
    gvfs.enable = true; # монтирование, корзина и прочее
    tumbler.enable = true; # превью изображений
  };

  programs = {
    # dconf — low-level configuration system.
    dconf.enable = true;

    # опции файлового менеджера thunar (часть xfce)
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
}
