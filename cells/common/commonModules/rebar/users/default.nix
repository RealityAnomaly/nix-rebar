{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
let
  userType = lib.types.submodule ({ config, ... }: {
    options = {
      access = { wildcard = lib.mkEnableOption "Wildcard Access"; };

      deploy = {
        enable = lib.mkEnableOption "Deploy User";

        privileged = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description =
            "Whether to make the user privileged on the system or not";
        };
      };

      # user personal information
      contact = {
        firstName = lib.mkOption { type = lib.types.str; };
        lastName = lib.mkOption { type = lib.types.str; };
        fullName = lib.mkOption {
          type = lib.types.str;
          default = "${config.contact.firstName} ${config.contact.lastName}";
        };
        email = lib.mkOption { type = lib.types.str; };
        platforms = { github = lib.mkOption { type = lib.types.str; }; };
      };

      keys = {
        pgp = { fingerprint = lib.mkOption { type = lib.types.str; }; };
        ssh = lib.mkOption { type = lib.types.listOf lib.types.str; };
      };

      home = {
        enable = lib.mkEnableOption "home-manager";
        stateVersion = lib.mkOption {
          type = lib.types.str;
          description = "The version of the home state to use";
        };
      };
    };
  });
in {
  imports = [ root.rebar.users.deploy ];

  options.rebar.users = lib.mkOption { type = lib.types.attrsOf userType; };
}
