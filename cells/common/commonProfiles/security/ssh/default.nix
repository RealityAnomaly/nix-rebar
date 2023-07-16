{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [ root.security.ssh.well-known-hosts ];
}
