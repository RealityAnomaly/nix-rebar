{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  imports = [
    cell.nixosModules.default # import cell modules

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
