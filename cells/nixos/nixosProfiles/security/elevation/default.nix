{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  # Allow sudo from the @wheel group
  security.sudo.enable = true;
}
