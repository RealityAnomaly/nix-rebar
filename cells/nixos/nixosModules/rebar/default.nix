{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  imports = [ root.rebar.flake root.rebar.boot.serial root.rebar.networking ];
}
