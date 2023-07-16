{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, modulesPath, ... }: {
  imports =
    [ "${modulesPath}/virtualisation/amazon-image.nix" root.mixins.cloud-init ];

  config = {
    # Don't invoke nixos-rebuild on boot
    virtualisation.amazon-init.enable = false;

    # Use cloud-init instead
    services.cloud-init.enable = true;
  };
}
