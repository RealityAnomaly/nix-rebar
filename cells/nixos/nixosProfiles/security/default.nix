{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [
    root.security.certs.default
    root.security.elevation.default
    root.security.hardening.default
  ];

  users = {
    mutableUsers = lib.mkDefault false;

    # this group owns /persist/nixos configuration
    groups.sysconf.gid = 600;
  };
}
