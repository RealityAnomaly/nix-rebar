{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  imports = [ root.core.compat.binary-paths root.core.compat.workarounds ];
}
