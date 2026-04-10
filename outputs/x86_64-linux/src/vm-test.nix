{
  # ВАЖНО: неиспользуемые в этом файле args удалять нельзя:
  # haumea передаёт аргументы лениво,
  # они используются в `mylib.nixosSystem`, `mylib.colmenaSystem` и т.д.
  inputs,
  lib,
  myvars,
  mylib,
  system,
  genSpecialArgs,
  niri,
  ...
}@args:
let
  # 星野 アイ, Hoshino Ai
  name = "vm-test";
  base-modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # общие
        # "secrets/nixos.nix" — agenix + приватный mysecrets; для vm-test не подключаем
        "modules/nixos/desktop.nix"
        # только этот хост
        "hosts/${name}"
        # hardening NixOS
        # "hardening/profiles/default.nix"
        "hardening/nixpaks"
        "hardening/bwraps"
      ])
      ++ [
        {
          modules.desktop.fonts.enable = true;
          modules.desktop.wayland.enable = true;
          modules.desktop.gaming.enable = true;
        }
      ];
    home-modules = map mylib.relativeToRoot [
      "home/hosts/linux/${name}.nix"
    ];
  };

  modules-niri = {
    nixos-modules = [
      { programs.niri.enable = true; }
    ]
    ++ base-modules.nixos-modules;
    home-modules = base-modules.home-modules;
  };
in
{
  nixosConfigurations = {
    "${name}-niri" = mylib.nixosSystem (modules-niri // args);
  };

  # iso для хостов с desktop environment
  packages = {
    "${name}-niri" = inputs.self.nixosConfigurations."${name}-niri".config.formats.iso;
  };
}
