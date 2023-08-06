{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  nix.settings = {
    substituters = [ "https://nixpkgs-wayland.cachix.org" ];
    trusted-public-keys = [
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
}
