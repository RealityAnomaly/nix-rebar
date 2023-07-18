{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs.lib) nixosSystem;
  cfg = config.rebar;

  linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] nixpkgs.system;

  builder = nixosSystem {
    system = linuxSystem;
    modules = [
      "${pkgs}/nixos/modules/profiles/macos-builder.nix"
      { virtualisation.host.pkgs = nixpkgs.legacyPackages."${linuxSystem}"; }
    ];
  };
in {
  options.rebar.darwin.local-builder = {
    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of jobs to run in parallel on the local builder";
    };
  };

  config = {
    nix = {
      distributedBuilds = true;
      buildMachines = [{
        inherit (cfg.darwin.local-builder) maxJobs;
        hostName = "ssh://builder@localhost";
        system = linuxSystem;
        supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
      }];
    };

    launchd.daemons.darwin-builder = {
      command =
        "${builder.config.system.build.macos-builder-installer}/bin/create-builder";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/darwin-builder.log";
        StandardErrorPath = "/var/log/darwin-builder.log";
      };
    };
  };
}
