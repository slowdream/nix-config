{
  lib,
  inputs,
  ...
}@args:
let
  inherit (inputs) haumea;

  # Все flake outputs для этой архитектуры system.
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  # Имена nix-файлов избыточны — убираем.
  dataWithoutPaths = builtins.attrValues data;

  # Слить данные всех машин в один attribute set.
  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.nixosConfigurations or { }) dataWithoutPaths
    );
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths);
    # у colmena есть meta — merge аккуратно
    colmenaMeta = {
      nodeNixpkgs = lib.attrsets.mergeAttrsList (
        map (it: it.colmenaMeta.nodeNixpkgs or { }) dataWithoutPaths
      );
      nodeSpecialArgs = lib.attrsets.mergeAttrsList (
        map (it: it.colmenaMeta.nodeSpecialArgs or { }) dataWithoutPaths
      );
    };
    colmena = lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) dataWithoutPaths);
  };
in
outputs
// {
  inherit data; # для отладки

  # unit tests NixOS
  evalTests = haumea.lib.loadEvalTests {
    src = ./tests;
    inputs = args // {
      inherit outputs;
    };
  };
}
