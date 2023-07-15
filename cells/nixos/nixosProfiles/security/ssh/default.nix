{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [
    root.core.security.ssh.well-known-hosts
  ];
}
