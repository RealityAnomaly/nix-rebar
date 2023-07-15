{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
let l = inputs.nixpkgs.lib // builtins;
in {
  imports =
    [ root.core.nix.optimise-store ];

  # These should (must?) be enabled in any recent multi-user Nix installation,
  # and yet they remain disabled by default in nix-darwin...
  services.nix-daemon.enable = l.mkForce true;
  nix.configureBuildUsers = l.mkForce true;

  # Administrative users on Darwin systems are part of the admin group.
  nix.settings.trusted-users = [ "@admin" ];

  nix.distributedBuilds = l.mkDefault false;

  # FIXME: currently requires running `nix run nixpkgs#darwin.builder`
  # manually in a separate shell session
  # nix.nixos-builder-vm.enable = true;

  # FIXME: needs flake-compat
  # nix.nixPath = mkBefore ["darwin-config=${self}"];
}
