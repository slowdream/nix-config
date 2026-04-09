{
  pkgs,
  pkgs-master,
  nixpak,
  ...
}:
let
  callArgs = {
    mkNixPak = nixpak.lib.nixpak {
      inherit (pkgs) lib;
      inherit pkgs;
    };
    safeBind = sloth: realdir: mapdir: [
      (sloth.mkdir (sloth.concat' sloth.appDataDir realdir))
      (sloth.concat' sloth.homeDir mapdir)
    ];
  };
  wrapper = _pkgs: path: (_pkgs.callPackage path callArgs);
in
{
  # Добавить nixpak-обёртки приложений в nixpkgs и ссылаться на них из home-manager или других модулей NixOS
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = wrapper super ./qq.nix;
        telegram-desktop = wrapper super ./telegram-desktop.nix;
        firefox = wrapper super ./firefox.nix;
      };
    })
  ];
}
