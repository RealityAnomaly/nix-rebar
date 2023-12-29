{ root, inputs, cell, lib, }:
let
  inherit (inputs) haumea;
  inherit (inputs.nixt.lib) nixt;
  inherit (root) mapFlattenAttrs;
in prefix: src: _inputs:
let
  tree = haumea.lib.load {
    inherit src;
    loader =
      [ (haumea.lib.matchers.extension "spec.nix" haumea.lib.loaders.path) ];
    transformer = [ haumea.lib.transformers.liftDefault ];
  };
in mapFlattenAttrs (_cursor: path:
  let cursor = [ prefix ] ++ _cursor;
  in lib.nameValuePair
  (lib.removeSuffix ".spec" (lib.concatStringsSep "__" cursor)) {
    inherit cursor path;
    value = import path ({
      inherit lib;
    } // _inputs // {
      # inputs.self is too noisy for 'check-augmented-cell-inputs'
      inputs = removeAttrs _inputs.inputs [ "self" ];
    });
  }) tree
