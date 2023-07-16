{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  nix.settings = {
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}