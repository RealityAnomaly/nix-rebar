{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, modulesPath, ... }: {
  imports = [ root.platforms.hetzner-online.default ];

  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
