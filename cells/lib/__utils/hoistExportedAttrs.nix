{ lib }:

key:

let
  inherit (lib) recursiveUpdate optionalAttrs;

  concatMapAttrsWith = import ./concatMapAttrsWith.nix { inherit lib; };

in cursor: attrs:

let
  toplevel = cursor == [ ];
  result = concatMapAttrsWith recursiveUpdate (file: value: {
    # strip exports attr from the atrribute sets
    ${file} = if value ? ${key} then removeAttrs value [ key ] else value;
    ${key} = optionalAttrs (value ? ${key}) value.${key};
  }) attrs;
in if toplevel && (result ? ${key}) then
  result.${key} // (removeAttrs result [ key ])
else
  result
