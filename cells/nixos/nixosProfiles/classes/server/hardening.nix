{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  # Extra security hardening options for servers
  nix.settings = {
    allowed-users = [ "@wheel" ];
    trusted-users = [ "root" "@wheel" ];
  };
}
