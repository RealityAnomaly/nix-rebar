{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [ root.rebar.flake root.rebar.host root.rebar.users ];
  options.rebar = { enable = lib.mkEnableOption "Rebar"; };
}
