{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  # TODO: также протестировать home-manager.
  home-modules ? [ ],
  myvars,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
pkgs.testers.runNixOSTest {
  name = "NixOS Tests for Idols Ruby";

  node = {
    inherit pkgs;
    specialArgs = genSpecialArgs system;
    pkgsReadOnly = false;
  };

  nodes = {
    ruby.imports = nixos-modules;
  };

  # Узлы доступны как объекты Python и как hostname в виртуальной сети
  testScript = ''
    ruby.wait_for_unit("network-online.target")

    ruby.succeed("curl https://baidu.com")
  '';
}
