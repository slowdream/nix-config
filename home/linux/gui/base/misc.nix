{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # GUI
    # читалка (.epub/.mobi/...)
    # .pdf не поддерживает
    foliate

    # удалённый рабочий стол (RDP)
    remmina
    freerdp # для remmina

    # свои hardened-пакеты
    nixpaks.qq
    nixpaks.telegram-desktop
    # qqmusic
    bwraps.wechat
    # discord # слишком частые обновления — web-версия
  ];

  # fontconfig подхватывает шрифты из home.packages
  # Сами шрифты — на уровне системы, не пользователя
  fonts.fontconfig.enable = false;
}
