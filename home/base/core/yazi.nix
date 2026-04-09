{ pkgs, ... }:
{
  # файловый менеджер в терминале
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    # Менять рабочую директорию при выходе из Yazi
    enableBashIntegration = true;
    enableNushellIntegration = true;
    shellWrapperName = "yy";
    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };
}
