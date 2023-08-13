{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  # These UI-enhancement plugins come at an even higher performance cost than
  # completion and do not belong in system configuration at all.
  programs.zsh = {
    enableFzfCompletion = lib.mkForce false;
    enableFzfGit = lib.mkForce false;
    enableFzfHistory = lib.mkForce false;
    enableSyntaxHighlighting = lib.mkForce false;
  };
}
