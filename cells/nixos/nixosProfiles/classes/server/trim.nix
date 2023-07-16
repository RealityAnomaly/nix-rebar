# This file collects configuration which disables unnecessary overhead on servers by default
{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  # Disable documentation
  # Notice this also disables --help for some commands such as nixos-rebuild
  documentation = {
    enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    man.enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
  };

  # No need for fonts on a server
  fonts.fontconfig.enable = lib.mkDefault false;

  # Print the URL instead on servers
  environment.variables.BROWSER = "echo";

  # No need for sound on a server
  sound.enable = false;
  xdg.sounds.enable = false;

  services.udisks2.enable = false;
}
