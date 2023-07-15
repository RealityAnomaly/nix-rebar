{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  sops.defaultSopsFile = cell.data.secrets.global;
}
