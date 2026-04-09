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
  name = "kubevirt-youko";
  tags = [
    name
    "virt-youko"
  ];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # общие
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        # только этот хост
        "hosts/k8s/${name}"
      ])
      ++ [
        {
          modules.secrets.server.kubernetes.enable = true;
          modules.secrets.preservation.enable = true;
        }
      ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // { inherit tags ssh-user; });

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
}
