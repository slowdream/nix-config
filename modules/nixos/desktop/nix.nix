{ config, lib, ... }:
let
  secrets = lib.attrByPath [ "age" "secrets" ] { } config;
in
{
  nix.extraOptions = lib.mkIf (secrets ? "nix-access-tokens") ''
    !include ${secrets."nix-access-tokens".path}
  '';
}
