{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  nix.settings = {
    substituters = [ "https://numtide.cachix.org" ];
    trusted-substituters = [ "https://numtide.cachix.org" ];
    trusted-public-keys =
      [ "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" ];
  };
}
