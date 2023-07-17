{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
let
  inherit (inputs) cells;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  cfg = config.rebar;
  isNixos = isLinux && !isDarwin;
  isEligiblePlatform = isLinux || isDarwin;

  # cells pulled from the input flake
  flakeCells = cfg.inputs.cells;

  userType = lib.types.submodule ({ _config, ... }: {
    options = {
      enable = lib.mkEnableOption "User";

      privileged = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description =
          "Whether to make the user privileged on the system or not";
      };

      # user personal information
      contact = {
        firstName = lib.mkOption { type = lib.types.str; };
        lastName = lib.mkOption { type = lib.types.str; };
        fullName = lib.mkOption {
          type = lib.types.str;
          default = "${_config.contact.firstName} ${_config.contact.lastName}";
        };
        email = lib.mkOption { type = lib.types.str; };
        platforms = { github = lib.mkOption { type = lib.types.str; }; };
      };

      keys = {
        pgp = { fingerprint = lib.mkOption { type = lib.types.str; }; };
        ssh = lib.mkOption { type = lib.types.listOf lib.types.str; };
      };
    };
  });
in {
  options.rebar.users = lib.mkOption { type = lib.types.attrsOf userType; };

  config = let
    enabledUsers = lib.filterAttrs (_: user: user.enable) cfg.users;
    privilegedUsers = lib.filterAttrs (_: user: user.privileged) enabledUsers;
    privilegedGroups =
      (lib.optional config.networking.networkmanager.enable "networkmanager")
      ++ (lib.optional config.services.mysql.enable "mysql")
      ++ (lib.optional config.virtualisation.docker.enable "docker");
  in lib.mkMerge [
    {
      # pull in default per-user metadata from the common cell
      rebar.users = flakeCells.common.data.peers.users;
    }
    (lib.mkIf (cfg.enable && isEligiblePlatform) {
      users.users = lib.mapAttrs (name: user:
        {
          home = cells.lib.functions.systems.homePath pkgs name;
          shell = lib.mkIf isDarwin (lib.mkDefault pkgs.zsh);
        } // (lib.optionalAttrs isNixos {
          # determine what groups we should add the user to automatically
          extraGroups = lib.mkIf user.privileged privilegedGroups;
        })) enabledUsers;

      # add the users to groups if they are privileged
      users.groups = let
        groups = [ "secrets" "keys" ] ++ (if isNixos then [ "wheel" ] else [ ]);
      in builtins.listToAttrs (map (name: {
        inherit name;
        value = { members = privilegedUsers; };
      }) groups);
    })
  ];
}
