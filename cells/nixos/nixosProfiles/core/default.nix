{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }:
let inherit (inputs) cells;
in {
  imports = [
    cell.nixosModules.default # import cell modules

    # import the base profile for all platforms
    cells.common.commonProfiles.core.default

    # third-party modules we also always load
    inputs.disko.nixosModules.disko
    inputs.ragenix.nixosModules.age
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence

    # default profiles for this profile
    root.core.boot.default
    root.core.hardware.default
    root.core.networking.default
    root.core.security.default
    root.core.services.default
    root.core.storage.default
    root.core.utilities.default
  ];
}
