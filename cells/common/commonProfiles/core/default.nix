{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [
    # import the common modules
    cell.commonModules.default

    # default profiles for this profile
    root.core.nix.default
    root.core.secrets.default
    root.core.security.default
    root.core.shells.default
    root.core.environment
  ];
}
