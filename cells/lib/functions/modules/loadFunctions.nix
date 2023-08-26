{ inputs, cell, lib, }:
let
  inherit (inputs) haumea;
  hoistExportedAttrs = import ./__utils/hoistExportedAttrs.nix { inherit lib; };
  nixNoTests = import ./../haumea/matchers/nixNoTests.nix { inherit lib; };
in src: _inputs:
haumea.lib.load {
  inherit src;
  transformer =
    [ (hoistExportedAttrs "__export") haumea.lib.transformers.liftDefault ];
  loader = [ (nixNoTests haumea.lib.loaders.default) ];
  inputs = { inherit lib; } // _inputs;
}
