_inputs@{ cell, inputs, }:
let
  pkgs = inputs.nixpkgs;
  inherit (inputs) hive self;
  inherit (pkgs) lib system;

  nixosLib = import "${pkgs.path}/nixos/lib" { inherit system pkgs; };

  moduleTests = {
    # this test actually runs the server module in a virtual machine
    server = nixosLib.runTest {
      name = "server";
      hostPkgs = pkgs;

      nodes.machine = { nodes, ... }: {
        imports = [ cell.nixosProfiles.classes.server.default ];
        networking.hostName = "machine";
      };

      testScript = ''
        machine.wait_for_unit("sshd.service")
        # TODO: what else to test for?
      '';
    };
  };

  # Only check the configurations for the current system
  sysConfigs =
    let nixosConfigurations = hive.collect self "nixosConfigurations";
    in lib.filterAttrs (_name: value: value.pkgs.system == system)
    nixosConfigurations;

  # Add all the nixos configurations to the checks
  nixosChecks = lib.mapAttrs' (name: value: {
    name = "nixos-${name}";
    value = value.config.system.build.toplevel;
  }) sysConfigs;
in nixosChecks // (lib.optionalAttrs pkgs.stdenv.isLinux moduleTests)
