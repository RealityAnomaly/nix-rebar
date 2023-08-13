{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
