{
  config,
  myvars,
  ...
}:
let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in
rec {
  home.homeDirectory = "/home/${myvars.username}";

  # переменные окружения при логине
  home.sessionVariables = {
    # порядок в ~
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
    WINEPREFIX = d + "/wine";

    # с этой переменной i3 не стартует
    # issue:
    #   https://github.com/sddm/sddm/issues/871
    # XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    # приложения по умолчанию
    BROWSER = "firefox";

    # прокрутка в git diff
    DELTA_PAGER = "less -R";
  };
}
