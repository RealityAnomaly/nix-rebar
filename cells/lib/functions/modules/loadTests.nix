{ root, inputs, cell, lib, }:
let
  inherit (inputs) haumea;
  inherit (inputs.nixt.lib) nixt;
  inherit (root) flattenAttrs;
in src: _inputs:
let
  tree = haumea.lib.load {
    inherit src;
    loader =
      [ (haumea.lib.matchers.extension "spec.nix" haumea.lib.loaders.path) ];
    transformer = [ haumea.lib.transformers.liftDefault ];
  };
in map (path: nixt.block' path (import path ({ inherit lib; } // _inputs)))
(lib.attrValues (flattenAttrs "_" tree))
