{
  lib,
  pkgs-master,
  ...
}:

{
  programs.vscode = {
    enable = true;
    package = pkgs-master.vscode.override {
      commandLineArgs = [
        # https://code.visualstudio.com/docs/configure/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code
        # Для любого пакета с Secret Service API
        # (gnome-keyring, kwallet5, KeepassXC)
        "--password-store=gnome-libsecret"
      ];
    };
  };
}
