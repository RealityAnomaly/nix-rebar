# counts the number of attributes in a set
{ root, inputs, cell, }:
let
  inherit (builtins) attrNames;
  inherit (inputs.nixpkgs.lib) length;
in set: length (attrNames set)
