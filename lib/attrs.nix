# https://github.com/NixOS/nixpkgs/blob/master/lib/attrsets.nix
{ lib, ... }:
{
  # Собрать attrset из списка имён.
  #
  #   lib.genAttrs [ "foo" "bar" ] (name: "x_" + name)
  #     => { foo = "x_foo"; bar = "x_bar"; }
  listToAttrs = lib.genAttrs;

  # Обновить только значения в attrset.
  #
  #   mapAttrs
  #   (name: value: ("bar-" + value))
  #   { x = "a"; y = "b"; }
  #     => { x = "bar-a"; y = "bar-b"; }
  inherit (lib.attrsets) mapAttrs;

  # Обновить и ключи, и значения attrset.
  #
  #   mapAttrs'
  #   (name: value: nameValuePair ("foo_" + name) ("bar-" + value))
  #   { x = "a"; y = "b"; }
  #     => { foo_x = "bar-a"; foo_y = "bar-b"; }
  inherit (lib.attrsets) mapAttrs';

  # Слить список attrset в один. Похоже на `a // b`, но для списка attrset.
  # ВАЖНО: последний attrset перекрывает предыдущие!
  #
  #   mergeAttrsList
  #   [ { x = "a"; y = "b"; } { x = "c"; z = "d"; } { g = "e"; } ]
  #   => { x = "c"; y = "b"; z = "d"; g = "e"; }
  inherit (lib.attrsets) mergeAttrsList;

  # Свернуть attrset в строку.
  #
  #   attrsets.foldlAttrs
  #   (acc: name: value: acc + "\nexport ${name}=${value}")
  #   "# A shell script"
  #   { x = "a"; y = "b"; }
  #     =>
  #     ```
  #     # A shell script
  #     export x=a
  #     export y=b
  #    ````
  inherit (lib.attrsets) foldlAttrs;
}
