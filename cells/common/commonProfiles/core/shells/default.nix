{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [ root.core.shells.fish root.core.shells.zsh ];
}
