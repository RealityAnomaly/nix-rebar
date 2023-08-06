{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  services.tcsd.enable = true;

  environment.systemPackages = with pkgs; [ tpm-tools ];
}
