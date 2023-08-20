# Like `tryEval`, but recursive.
{ root, inputs, cell, }:
let
  inherit (builtins) isAttrs tryEval;
  inherit (inputs.nixpkgs.lib) mapAttrs;

  recurse = mapAttrs (_n: v:
    let
      eval = tryEval v;
      value = if eval.success then eval.value else null;
    in if isAttrs value then recurse value else value);
in recurse
