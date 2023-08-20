# flattens an attribute set by concatenating the paths of all its leaves
{ root, inputs, cell, }:
let
  inherit (builtins) isAttrs;
  inherit (inputs.nixpkgs.lib) concatStringsSep flatten mapAttrsToList;
  inherit (root.utilities.attrs) recursiveMerge;
in sep: attrs:
let
  f = cursor: value:
    if isAttrs value then
      flatten (mapAttrsToList (k: f (cursor ++ [ k ])) value)
    else {
      "${concatStringsSep sep cursor}" = value;
    };
in recursiveMerge (f [ ] attrs)
