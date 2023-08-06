{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    age
    age-plugin-yubikey
    rage
    sops
    ssh-to-age
  ];
}
