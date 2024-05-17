{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  # TODO: for some reason, this causes the download to time out
  #manual.manpages.enable = false;
}
