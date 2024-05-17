{ inputs, cell, ... }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;

  loadFunctions = import ./functions/modules/_utils/loadFunctions.nix {
    inherit inputs cell lib;
  };
in loadFunctions ./functions { inherit inputs cell lib; }
