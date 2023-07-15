{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  boot = {
    #tmpOnTmpfs = true; # TODO only if "big enough" ?

    loader = {
      grub.configurationLimit = 5;

      systemd-boot = {
        # disables init=/bin/sh backdoor
        editor = lib.mkDefault false;
        configurationLimit = 5;
      };
    };

    # Use systemd during boot as well on systems except:
    # - systems that require networking in early-boot
    # - systems with raids as this currently require manual configuration (https://github.com/NixOS/nixpkgs/issues/210210)
    # - for containers we currently rely on the `stage-2` init script that sets up our /etc
    initrd.systemd.enable = lib.mkDefault (
      !config.boot.initrd.network.enable &&
      !config.boot.initrd.services.swraid.enable &&
      !config.boot.isContainer &&
      !config.boot.growPartition
    );

    # Ensure a clean & sparkling /tmp on fresh boots.
    tmp.cleanOnBoot = lib.mkDefault true;
  };
}
