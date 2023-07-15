{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  services.tcsd.enable = true;

  environment.systemPackages = with pkgs; [ tpm-tools ];
}
