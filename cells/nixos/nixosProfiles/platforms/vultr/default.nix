{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
{
  imports = [
    root.mixins.cloud-init
  ];

  services.cloud-init.settings.datasource_list = [ "Vultr" ];
  services.cloud-init.settings.datasource.Vultr = { };
}