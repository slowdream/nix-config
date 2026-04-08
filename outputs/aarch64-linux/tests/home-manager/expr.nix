{
  myvars,
  lib,
  outputs,
}:
let
  username = myvars.username;
in
lib.genAttrs hosts (
  name: outputs.nixosConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
)
