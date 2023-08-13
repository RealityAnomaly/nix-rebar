{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
let

  hostUserType = lib.types.submodule ({ config, ... }: {
    options = {
      privileged = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description =
          "Whether to make the user privileged on the system or not";
      };

      keys = {
        age = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        ssh = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    };
  });

  hostType = lib.types.submodule ({ config, ... }: {
    options = {
      users = lib.mkOption {
        type = lib.types.attrsOf hostUserType;
        default = { };
        description =
          "System-specific configuration for each user on this system";
      };

      keys = {
        age = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        ssh = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };

      # todo
      network = lib.mkOption { type = lib.types.str; };
    };
  });
in {
  options.rebar.hosts = lib.mkOption { type = lib.types.attrsOf hostType; };
}
