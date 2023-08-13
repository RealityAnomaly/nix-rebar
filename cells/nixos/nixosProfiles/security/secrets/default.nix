{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  sops.defaultSopsFile = cell.data.secrets.global;
}
