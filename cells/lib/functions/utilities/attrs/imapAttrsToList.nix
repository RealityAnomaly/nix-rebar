# maps attrs to list with an extra i iteration parameter
{ root, inputs, cell, }:
let
  inherit (builtins) attrNames;
  inherit (inputs.nixpkgs.lib) length genList elemAt;
in f: set:
let keys = attrNames set;
in genList (n:
  let
    key = elemAt keys n;
    value = set.${key};
  in f n key value) (length keys)
