/* *
   Extracts a single name-value attribute pair from the specified attribute set using the predicate
*/
{ root, inputs, cell, }:
let
  inherit (builtins) attrNames;
  inherit (inputs.nixpkgs.lib) filterAttrs head;
in predicate: attrs:
let
  filtered = filterAttrs predicate attrs;
  name = head (attrNames filtered);
in {
  inherit name;
  value = attrs.${name};
}
