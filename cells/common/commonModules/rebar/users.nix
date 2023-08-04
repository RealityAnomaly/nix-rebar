{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
let
  inherit (inputs) cells;
  inherit (cells.lib) functions;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  inherit (functions.modules) extractSuites;

  cfg = config.rebar;
  isNixos = isLinux && !isDarwin;
  isEligiblePlatform = isLinux || isDarwin;

  userType = lib.types.submodule ({ config, ... }: {
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
  options.rebar.users = lib.mkOption { type = lib.types.attrsOf userType; };

  config = let
    enabledUsers = lib.filterAttrs (_: user: user.enable) cfg.users;
    privilegedUsers = lib.filterAttrs (_: user: user.privileged) enabledUsers;
    privilegedGroups = [ "wheel" ]
      ++ (lib.optional config.networking.networkmanager.enable "networkmanager")
      ++ (lib.optional config.services.mysql.enable "mysql")
      ++ (lib.optional config.virtualisation.docker.enable "docker");
  in lib.mkMerge [
    (lib.mkIf (cfg.enable && isEligiblePlatform) {
      assertions = [{
        assertion = (builtins.length (builtins.attrNames cfg.users)) > 0;
        message = "At least one user must be defined";
      }];

      users.users = lib.mapAttrs (name: user:
        {
          home = cells.lib.functions.systems.homePath pkgs name;
          shell = lib.mkIf isDarwin (lib.mkDefault pkgs.zsh);
        } // (lib.optionalAttrs isNixos {
          # determine what groups we should add the user to automatically
          group = name;
          isNormalUser = true;
          extraGroups = lib.mkIf user.privileged privilegedGroups;
          openssh.authorizedKeys.keys = user.keys.ssh;
        })) enabledUsers;

      # add the users to groups if they are privileged
      users.groups = let
        groups = [ "secrets" "keys" ] ++ (if isNixos then [ "wheel" ] else [ ]);
      in builtins.listToAttrs (map (name: {
        inherit name;
        value = { members = privilegedUsers; };
      }) groups);

      home-manager.users = lib.mapAttrs (name: user: _':
        let
          cells' = cfg.inputs.cells;
          homeSuites =
            extractSuites cfg.host [ ] cells'.common.users.${name}.homeSuites;
        in {
          imports = homeSuites;
          home = { inherit (user.home) stateVersion; };
        }) (lib.filterAttrs (_: user: user.home.enable) enabledUsers);
    })
  ];
}
