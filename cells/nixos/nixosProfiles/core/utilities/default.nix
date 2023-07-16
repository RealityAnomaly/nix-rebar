{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
{
  imports = [
    root.core.utilities.upgrade-diff
  ];

  programs = {
    # setcap wrappers for security hardening
    mtr.enable = true;
    traceroute.enable = true;

    # enable neovim as the default text editor
    neovim = {
      enable = lib.mkDefault true;
      viAlias = lib.mkDefault true;
      vimAlias = lib.mkDefault true;
    };

    # set required defaults for git
    git = {
      enable = true;

      # disable git "safe directory" feature as it breaks rebuilds
      # TODO: is this still required as of 2023?
      config.safe.directory = [ "*" ];
    };
  };
}
