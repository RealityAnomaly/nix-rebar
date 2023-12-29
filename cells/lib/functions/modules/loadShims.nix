{ inputs, cell, lib, }:
let suffix = "/default.shim.nix";

in src: _inputs:
let
  imports = let
    files = builtins.readDir src;
    p = _n: v: v == "directory";
  in lib.filterAttrs p files;

  f = n: _:
    let
      path = "${src}/${n}";
      full = "${path}${suffix}";
    in if builtins.pathExists full then import full _inputs else null;
in lib.filterAttrs (_: v: v != null) (lib.mapAttrs f imports)
