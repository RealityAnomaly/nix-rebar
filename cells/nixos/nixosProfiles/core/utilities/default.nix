{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
{
  imports = [
    root.core.utilities.upgrade-diff
  ];
}
