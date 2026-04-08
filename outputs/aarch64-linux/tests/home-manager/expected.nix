{
  myvars,
  lib,
}:
let
  username = myvars.username;
in
lib.genAttrs hosts (_: "/home/${username}")
