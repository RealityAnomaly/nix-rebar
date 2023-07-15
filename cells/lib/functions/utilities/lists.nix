{ root, inputs, cell, }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  inherit (lib) filter;
in rec {
  # filters out empty strings and null objects from a list
  filterListNonEmpty = l: (filter (x: (x != "" && x != null)) l);
}
