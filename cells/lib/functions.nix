{ inputs, cell, ... }:
let
  inherit (inputs) haumea nixpkgs;
  inherit (nixpkgs) lib;

  hoistExportedAttrs =
    import ./__utils/hoistExportedAttrs.nix { inherit (nixpkgs) lib; };
in haumea.lib.load {
  src = ./functions;
  transformer =
    [ (hoistExportedAttrs "__export") haumea.lib.transformers.liftDefault ];
  inputs = { inherit inputs cell lib; };
}
