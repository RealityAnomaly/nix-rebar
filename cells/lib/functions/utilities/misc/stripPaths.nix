# strips all store paths recursively from an attribute set
{ root, inputs, cell, lib, }:
let
  inherit (builtins) isAttrs isList isPath isString;
  inherit (lib) concatStringsSep hasPrefix imap0 length mapAttrs splitString;

  sanitiseSafe = path:
    let
      cursor = splitString "/" path;
      len = length cursor;
    in if len > 2 then
      concatStringsSep "/"
      (imap0 (i: v: if i == 3 then "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" else v)
        cursor)
    else
      path;

  f = value:
    if isAttrs value then
      mapAttrs (_: v: f v) value
    else if isList value then
      map f value
    else if ((isPath value) || (isString value))
    && (hasPrefix "/nix/store" value) then
      toString (sanitiseSafe (toString value))
    else
      value;
in f
