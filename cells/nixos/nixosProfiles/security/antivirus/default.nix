{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  # enables the clamav antivirus
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}
