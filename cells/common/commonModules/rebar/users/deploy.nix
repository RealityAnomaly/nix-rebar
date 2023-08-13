{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
let
  inherit (inputs) cells;
  inherit (cells.lib) functions;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  inherit (functions.modules) extractSuites;

  cfg = config.rebar;
  isNixos = isLinux && !isDarwin;
  isEligiblePlatform = isLinux || isDarwin;
in {
  config = let
    deployedUsers = lib.filterAttrs (_: user: user.deploy.enable) cfg.users;
    privilegedUsers =
      lib.filterAttrs (_: user: user.deploy.privileged) deployedUsers;
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

      users.users = lib.mkMerge [
        (lib.mapAttrs (name: user:
          {
            home = cells.lib.functions.systems.homePath pkgs name;
            shell = lib.mkIf isDarwin (lib.mkDefault pkgs.zsh);
          } // (lib.optionalAttrs isNixos {
            # determine what groups we should add the user to automatically
            group = name;
            isNormalUser = true;
            extraGroups = lib.mkIf user.privileged privilegedGroups;
            openssh.authorizedKeys.keys = user.keys.ssh;
          })) deployedUsers)

        # configure the base root and nixos users
        (lib.optionalAttrs isNixos (let
          wildcardUsers =
            lib.filterAttrs (_: user: user.access.wildcard) cfg.users;
          keys =
            (lib.concatMap (user: user.keys.ssh) (lib.attrValues wildcardUsers))
            ++ (lib.flatten (
              # concat keys derived from per-host keystores
              let
                hostUsers =
                  lib.mapAttrsToList (_: v: v.users) config.rebar.hosts;
              in map (n:
                lib.concatMap (user: user.keys.ssh) (lib.catAttrs n hostUsers))
              (lib.attrNames wildcardUsers)));
        in {
          root = { openssh.authorizedKeys.keys = keys; };
          nixos = {
            group = "nixos";
            isNormalUser = true;
            extraGroups = privilegedGroups;
            openssh.authorizedKeys.keys = keys;
          };
        }))
      ];

      # add the users to groups if they are privileged
      users.groups = let
        groups = [ "secrets" "keys" ] ++ (if isNixos then [ "wheel" ] else [ ]);
      in lib.mkMerge [
        (builtins.listToAttrs (map (name: {
          inherit name;
          value = { members = lib.mapAttrsToList (n: _: n) privilegedUsers; };
        }) groups))

        (lib.optionalAttrs isNixos { nixos.members = [ "nixos" ]; })
      ];

      home-manager.users = lib.mapAttrs (name: user: _':
        let
          cells' = cfg.inputs.cells;
          homeSuites =
            extractSuites cfg.host [ ] cells'.common.users.${name}.homeSuites;
        in {
          imports = homeSuites;
          home = { inherit (user.home) stateVersion; };
        }) (lib.filterAttrs (_: user: user.home.enable) deployedUsers);
    })
  ];
}
