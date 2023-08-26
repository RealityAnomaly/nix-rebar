{ root, inputs, cell, lib, }: rec {
  __export = { inherit optionalPath optionalPathImport stripPaths; };

  # if path exists, evaluate expr with it, otherwise return other
  optionalPath = path: expr: other:
    if builtins.pathExists path then expr path else other;

  # if path exists, import it, otherwise return other
  optionalPathImport = path: optionalPath path import;

  # strips all store paths recursively from an attribute set
  stripPaths = let
    sanitiseSafe = path:
      let
        cursor = lib.splitString "/" path;
        len = lib.length cursor;
      in if len > 2 then
        lib.concatStringsSep "/" (lib.imap0
          (i: v: if i == 3 then "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" else v)
          cursor)
      else
        path;

    f = value:
      if builtins.isAttrs value then
        lib.mapAttrs (_: v: f v) value
      else if builtins.isList value then
        map f value
      else if ((builtins.isPath value) || (builtins.isString value))
      && (lib.hasPrefix "/nix/store" value) then
        toString (sanitiseSafe (toString value))
      else
        value;
  in f;
}
