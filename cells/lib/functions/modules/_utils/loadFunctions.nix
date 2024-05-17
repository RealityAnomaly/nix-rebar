{ inputs, cell, lib, }:
let
  inherit (inputs) haumea;
  hoistExportedAttrs = import ./hoistExportedAttrs.nix { inherit lib; };
  nixNoTests = import ./../../haumea/matchers/nixNoTests.nix { inherit lib; };
  liftDefaultSafe =
    import ./../../haumea/transformers/liftDefaultSafe.nix { inherit lib; };
in src: _inputs:
haumea.lib.load {
  inherit src;
  transformer = [ (hoistExportedAttrs "__export") liftDefaultSafe ];
  loader = [ (nixNoTests haumea.lib.loaders.default) ];
  inputs = _inputs;
}
