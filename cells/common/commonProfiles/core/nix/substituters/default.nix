{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  imports = [
    root.core.nix.substituters.garnix
    root.core.nix.substituters.nix-community
    root.core.nix.substituters.nixpkgs-update
    root.core.nix.substituters.nixpkgs-wayland
  ];

  nix.settings = {
    # Fallback quickly if substituters are not available.
    connect-timeout = 5;

    substituters = [ "https://cache.nixos.org/" ];
    trusted-substituters = [ "https://cache.nixos.org/" ];
    trusted-public-keys =
      [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };
}
