{
  lib,
  outputs,
}:
let
  specialExpected = { };
  specialHostNames = builtins.attrNames specialExpected;

  otherHosts = builtins.removeAttrs outputs.nixosConfigurations specialHostNames;
  otherHostsNames = builtins.attrNames otherHosts;
  # у остальных хостов hostName совпадает с именем в nixosConfigurations
  otherExpected = lib.genAttrs otherHostsNames (name: name);
in
(specialExpected // otherExpected)
