# given a list of attribute sets, merges the keys specified by "names" from "defaults" into them if they do not exist
{ root, inputs, cell, }:
let
  inherit (builtins) hasAttr;
  inherit (inputs.nixpkgs.lib) mapAttrs' nameValuePair genAttrs;
in sets: names: defaults:
(mapAttrs' (n: v:
  nameValuePair n (v // genAttrs names
    (name: (if hasAttr name v then v.${name} else defaults.${name})))) sets)
