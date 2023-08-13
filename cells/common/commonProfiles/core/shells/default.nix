{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  imports = [ root.core.shells.fish root.core.shells.zsh ];
}
