{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [ root.security.default ];
}
