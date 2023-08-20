# Recursively merges attribute sets **and** lists
{ root, inputs, cell, }:
let
  inherit (builtins) isAttrs isList;
  inherit (inputs.nixpkgs.lib)
    all concatLists head tail last unique zipAttrsWith;
in attrList:
let
  f = zipAttrsWith (n: values:
    if tail values == [ ] then
      head values
    else if all isList values then
      unique (concatLists values)
    else if all isAttrs values then
      f [ n ] values
    else
      last values);
in f attrList
