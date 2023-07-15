{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
{
  environment.systemPackages = with pkgs; [
    age
    age-plugin-yubikey
    rage
    sops
    ssh-to-age
  ];
}
