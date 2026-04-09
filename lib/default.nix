{ lib, ... }:
{
  colmenaSystem = import ./colmenaSystem.nix;
  macosSystem = import ./macosSystem.nix;
  nixosSystem = import ./nixosSystem.nix;

  attrs = import ./attrs.nix { inherit lib; };

  genK3sServerModule = import ./genK3sServerModule.nix;
  genK3sAgentModule = import ./genK3sAgentModule.nix;
  genKubeVirtHostModule = import ./genKubeVirtHostModule.nix;
  genKubeVirtGuestModule = import ./genKubeVirtGuestModule.nix;

  # путь относительно корня репозитория
  relativeToRoot = lib.path.append ../.;
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # включать каталоги
          || (
            (path != "default.nix") # пропускать default.nix
            && (lib.strings.hasSuffix ".nix" path) # включать .nix-файлы
          )
        ) (builtins.readDir path)
      )
    );
}
