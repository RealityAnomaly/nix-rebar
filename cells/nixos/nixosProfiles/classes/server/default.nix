{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [
    root.classes.server.hardening

    # enable SSH by default for servers
    root.security.sshd
  ];

  security = {
    sudo.wheelNeedsPassword = lib.mkDefault false;
    please.wheelNeedsPassword = lib.mkDefault false;
    doas.wheelNeedsPassword = lib.mkDefault false;
  };

  # disable to remove unnecessary overhead
  xdg.sounds.enable = false;
  services.udisks2.enable = false;
}
