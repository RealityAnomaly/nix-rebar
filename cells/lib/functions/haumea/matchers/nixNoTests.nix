{ lib, }:

let
  inherit (builtins) stringLength;
  inherit (lib) hasSuffix;

in f: {
  matches = file:
    hasSuffix ".nix" file && (!(hasSuffix ".spec.nix" file))
    && stringLength file > (stringLength ".nix" + 1);
  loader = f;
}
