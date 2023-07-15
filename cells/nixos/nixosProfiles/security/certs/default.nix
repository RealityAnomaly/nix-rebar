{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  security.pki.certificateFiles = [ ];
}
