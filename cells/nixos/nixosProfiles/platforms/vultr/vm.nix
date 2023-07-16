{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    root.platforms.vultr.default
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/vda" ];
}
