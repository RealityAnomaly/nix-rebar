{ lib, }:

let
  inherit (lib.attrsets)
    isAttrs unionOfDisjoint
    ;
in

_: mod: let
  default = mod.default or { };
# allow default to override the module if it's a simple value
in if ! isAttrs default then default else
  unionOfDisjoint (removeAttrs mod [ "default" ]) default
