{ inputs, cell, ... }:
let
  inherit (inputs) haumea nixpkgs;
  inherit (nixpkgs) lib;
in haumea.lib.load {
  src = ./data;
  transformer = haumea.lib.transformers.liftDefault;
  inputs = { inherit inputs cell lib; };
}
