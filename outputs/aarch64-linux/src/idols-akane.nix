{
  # ВАЖНО: неиспользуемые в этом файле args удалять нельзя:
  # haumea передаёт аргументы лениво,
  # они используются в `mylib.nixosSystem`, `mylib.colmenaSystem` и т.д.
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  # 黒川 茜, Kurokawa Akane
  name = "akane";
  tags = [
    name
    "homelab-app"
  ];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # общие
        "secrets/nixos.nix"
        "modules/nixos/server/server-aarch64.nix"
        "modules/nixos/server/qemu-guest.nix"
        # только этот хост
        "hosts/idols-${name}"
      ])
      ++ [
      ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // { inherit tags ssh-user; });
}
