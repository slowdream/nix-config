{ config, pkgs, ... }:
{
  catppuccin.fcitx5.enable = false;
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # fcitx5 переписывает ~/.config/fcitx5/profile при смене метода ввода,
      # поэтому force при каждой сборке — без конфликта файлов
      force = true;
    };
    "mozc/config1.db".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/linux/gui/base/fcitx5/mozc-config1.db";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-configtool # GUI fcitx5
      fcitx5-gtk # gtk im module

      # 中文
      fcitx5-rime # 小鹤音形等 через rime
      # fcitx5-chinese-addons # вместо этого rime

      # 日本語
      # ctrl-i / F7 — катакана
      # ctrl-u / F6 — хирагана
      fcitx5-mozc-ut # Mozc + UT dictionary

      # 한국어
      fcitx5-hangul
    ];
  };
}
