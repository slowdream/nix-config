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
  name = "k3s-test-1-master-3";
  tags = [ name ];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # общие
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        "modules/nixos/server/kubevirt-hardware-configuration.nix"
        # только этот хост
        "hosts/k8s/${name}"
      ])
      ++ [
        { modules.secrets.server.kubernetes.enable = true; }
      ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // { inherit tags ssh-user; });

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.kubevirt;
}
