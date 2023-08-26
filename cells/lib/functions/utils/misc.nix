{ root, inputs, cell, lib, }: rec {
  __export = { inherit isIPv6 tryEval'; };

  # determines whether a given address is IPv6 or not
  isIPv6 = str: builtins.match ".*:.*" str != null;

  # Like `tryEval`, but recursive.
  tryEval' = let
    recurse = lib.mapAttrs (_n: v:
      let
        eval = builtins.tryEval v;
        value = if eval.success then eval.value else null;
      in if builtins.isAttrs value then recurse value else value);
  in recurse;
}
