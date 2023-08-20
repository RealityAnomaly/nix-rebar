# mapFilterAttrs ::
#   (name -> value -> bool )
#   (name -> value -> { name = any; value = any; })
#   attrs
{ root, inputs, cell, }:
let inherit (inputs.nixpkgs.lib) filterAttrs mapAttrs';
in seive: f: attrs: filterAttrs seive (mapAttrs' f attrs)
