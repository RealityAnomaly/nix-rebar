{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    boot = {
      growPartition = true;
      kernelParams = [ "console=tty0" ];

      loader = {
        timeout = 0;
        grub.device = "/dev/vda";
      };
    };

    services.cloud-init = {
      enable = true;
      network.enable = true;
    };
  };
}
