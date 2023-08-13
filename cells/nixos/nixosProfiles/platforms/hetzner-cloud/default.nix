{ root, inputs, cell, ... }:
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" root.mixins.cloud-init ];

  config = {
    boot.growPartition = true;
    boot.loader.grub.device = "/dev/sda";

    fileSystems."/" = lib.mkDefault {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    networking.useNetworkd = true;
    networking.useDHCP = false;
  };
}
