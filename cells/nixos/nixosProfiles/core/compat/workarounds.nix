{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  # Work around for https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  # This is pulled in by the container profile, but it seems broken and causes
  # unecessary rebuilds.
  environment.noXlibs = false;
}
