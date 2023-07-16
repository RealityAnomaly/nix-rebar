{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
