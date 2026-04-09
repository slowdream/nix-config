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
  # 星野 愛久愛海, Hoshino Akuamarin
  name = "aquamarine";
  tags = [
    "aqua"
    "homelab-network"
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
        { modules.secrets.server.application.enable = true; }
        { modules.secrets.server.operation.enable = true; }
        { modules.secrets.server.webserver.enable = true; }
        { modules.secrets.server.storage.enable = true; }
      ];
    home-modules = map mylib.relativeToRoot [
      "home/hosts/linux/idols-${name}.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // { inherit tags ssh-user; });

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.kubevirt;
}
