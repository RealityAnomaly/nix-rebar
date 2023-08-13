{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = lib.mkDefault true;
    shellInit = lib.mkDefault "";
    loginShellInit = lib.mkDefault "";
    interactiveShellInit = lib.mkDefault "";

    # Prompts/completions/widgets should never be initialised at the
    # system-level because it will need to be initialised a second time once the
    # user's zsh configs load.
    promptInit = lib.mkForce "";
    enableCompletion = lib.mkForce false;
    enableBashCompletion = lib.mkForce false;
  };
}
