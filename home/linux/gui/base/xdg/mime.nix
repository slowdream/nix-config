{
  xdg.configFile."mimeapps.list".force = true;

  # $XDG_CONFIG_HOME/mimeapps.list
  # desktop-файлы ищутся по $XDG_DATA_DIRS, проверка:
  #  echo $XDG_DATA_DIRS
  # системные .desktop:
  #   ls -l /run/current-system/sw/share/applications/
  # пользовательские (пример user ryan):
  #  ls /etc/profiles/per-user/ryan/share/applications/
  xdg.mimeApps = {
    enable = true;
    # `xdg-open` открывает URL нужным приложением
    defaultApplications =
      let
        browser = [
          "google-chrome.desktop"
          "firefox.desktop"
        ];
        editor = [
          "nvim.desktop"
          "Helix.desktop"
          "code.desktop"
          "code-insiders.desktop"
        ];
      in
      {
        "application/json" = browser;
        "application/pdf" = browser; # TODO: отдельный pdf viewer

        "text/html" = browser;
        "text/xml" = browser;
        "text/plain" = editor;
        "application/xml" = browser;
        "application/xhtml+xml" = browser;
        "application/xhtml_xml" = browser;
        "application/rdf+xml" = browser;
        "application/rss+xml" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-wine-extension-ini" = editor;

        # схемы URL
        "x-scheme-handler/about" = browser; # about: → browser
        "x-scheme-handler/ftp" = browser; # ftp: → browser
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        # https://github.com/microsoft/vscode/issues/146408
        "x-scheme-handler/vscode" = [ "code-url-handler.desktop" ]; # vscode://
        "x-scheme-handler/vscode-insiders" = [ "code-insiders-url-handler.desktop" ]; # vscode-insiders://
        "x-scheme-handler/zoommtg" = [ "Zoom.desktop" ];

        # прочие схемы — дефолтное приложение
        # "x-scheme-handler/unknown" = editor;

        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop " ];

        "audio/*" = [ "mpv.desktop" ];
        "video/*" = [ "mpv.desktop" ];
        "image/*" = [ "imv-dir.desktop" ];
        "image/gif" = [ "imv-dir.desktop" ];
        "image/jpeg" = [ "imv-dir.desktop" ];
        "image/png" = [ "imv-dir.desktop" ];
        "image/webp" = [ "imv-dir.desktop" ];

        "inode/directory" = [ "yazi.desktop" ];
      };

    associations.removed = {
      # ......
    };
  };
}
