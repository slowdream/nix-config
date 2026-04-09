{ pkgs, ... }:
{
  # все шрифты линкуются в /nix/var/nix/profiles/system/sw/share/X11/fonts
  fonts = {
    # использовать шрифты пользователя, а не дефолтные
    enableDefaultPackages = false;
    fontDir.enable = true;

    # шрифты заданы в /modules/base/fonts.nix, общие для NixOS и Darwin.
    # packages = [ ... ];

    fontconfig = {
      # дефолтные шрифты, заданные пользователем
      # https://catcat.cc/post/2021-03-07/
      defaultFonts = {
        serif = [
          # 西文: 衬线字体（笔画末端有修饰(衬线)的字体，通常用于印刷。）
          "Source Serif 4"
          # 中文: 宋体（港台称明體）
          "Source Han Serif SC" # 思源宋体
          "Source Han Serif TC"
        ];
        # SansSerif 也简写做 Sans, Sans 在法语中就是「without」或者「无」的意思
        sansSerif = [
          # 西文: 无衬线字体（指笔画末端没有修饰(衬线)的字体，通常用于屏幕显示）
          "Source Sans 3"
          # 中文: 黑体
          "LXGW WenKai Screen" # 霞鹜文楷 屏幕阅读版
          "Source Han Sans SC" # 思源黑体
          "Source Han Sans TC"
        ];
        # 等宽字体
        monospace = [
          # 中文
          "Maple Mono NF CN" # 中英文宽度完美 2:1 的字体
          "Source Han Mono SC" # 思源等宽
          "Source Han Mono TC"
          # 西文
          "JetBrainsMono Nerd Font"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      antialias = true; # 抗锯齿
      hinting.enable = false; # 禁止字体微调 - 高分辨率下没这必要
      subpixel = {
        rgba = "rgb"; # IPS 屏幕使用 rgb 排列
      };
    };
  };

  # https://wiki.archlinux.org/title/KMSCON
  services.kmscon = {
    # Использовать kmscon как виртуальную консоль вместо getty.
    # kmscon — userspace virtual terminal на базе KMS/DRI.
    # Богаче, чем стандартная linux console VT: полный unicode и при поддержке DRM на видеокарте обычно быстрее.
    enable = true;
    fonts = with pkgs; [
      {
        name = "Maple Mono NF CN";
        package = maple-mono.NF-CN-unhinted;
      }
      {
        name = "JetBrainsMono Nerd Font";
        package = nerd-fonts.jetbrains-mono;
      }
    ];
    extraOptions = "--term xterm-256color";
    extraConfig = "font-size=14";
    # Использовать ли 3D hardware acceleration для рендера консоли.
    hwRender = true;
  };
}
