{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  imports = [ root.security.ssh.well-known-hosts ];
}
