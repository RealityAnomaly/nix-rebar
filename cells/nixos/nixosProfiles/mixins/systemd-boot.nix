# Add this mixin to machines that boot with EFI
{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
{
  # Only enable during install
  #boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd-boot to boot EFI machines
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
}
