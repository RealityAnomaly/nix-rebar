{ root, inputs, cell, }:
let
  inherit (builtins) attrNames;
  inherit (inputs.nixpkgs.lib) concatMap;
  inherit (root.functions.utilities.attrs) recursiveMergeAttrsWithNames;
in f: sets: recursiveMergeAttrsWithNames (concatMap attrNames sets) f sets
