{ root, inputs, cell, ... }:
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ root.platforms.hetzner-online.default ];

  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
