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
  # 星野 瑠美衣, Hoshino Rubii
  name = "ruby";
  tags = [
    name
    "homelab-operation"
  ];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # общие
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        "modules/nixos/server/kubevirt-hardware-configuration.nix"
        # только этот хост
        "hosts/idols-${name}"
      ])
      ++ [
      ];
    home-modules = map mylib.relativeToRoot [
      # только этот хост
      "home/hosts/linux/idols-${name}.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // { inherit tags ssh-user; });

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.kubevirt;

  # тесты NixOS
  packages."${name}-nixos-tests" = import ../nixos-tests/idols-ruby.nix systemArgs;
}
