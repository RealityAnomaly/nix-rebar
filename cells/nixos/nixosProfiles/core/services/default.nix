{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  services = {
    # prefer free alternatives
    mysql.package = lib.mkOptionDefault pkgs.mariadb;

    # enable recommended settings by default for nginx
    nginx = {
      enableReload = lib.mkDefault true;

      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;
    };

    # enable the system MTA
    postfix.enable = lib.mkDefault true;
  };
}
