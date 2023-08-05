{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [
    root.rebar.flake
    root.rebar.host
    root.rebar.hosts.default
    root.rebar.users.default
  ];

  options.rebar = { enable = lib.mkEnableOption "Rebar"; };
}
