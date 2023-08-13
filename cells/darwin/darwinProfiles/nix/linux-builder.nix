{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }:
let
  inherit (inputs) nixpkgs nixos-stable;
  inherit (nixos-stable.lib) nixosSystem;
  cfg = config.rebar;

  inherit (nixpkgs) system;
  linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;

  # using nixos-unstable as this is a relatively new feature
  builder = nixosSystem {
    system = linuxSystem;
    modules = [
      "${nixos-stable}/nixos/modules/profiles/macos-builder.nix"
      {
        system.nixos.revision = lib.mkForce null;
        virtualisation = {
          host.pkgs = nixos-stable.legacyPackages."${system}";
          forwardPorts = lib.mkForce [{
            from = "host";
            host.address = "127.0.0.1";
            host.port = cfg.darwin.linux-builder.hostPort;
            guest.port = 22;
          }];
        };
      }
    ];
  };

  # A Bash script for running the builder
  runLinuxBuilderScript = pkgs.writeShellScriptBin "run-linux-builder" ''
    set -uo pipefail
    trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
    IFS=$'\n\t'
    mkdir -p "${cfg.darwin.linux-builder.dataDir}"
    cd "${cfg.darwin.linux-builder.dataDir}"
    ${builder.config.system.build.macos-builder-installer}/bin/create-builder
  '';
in {
  options.rebar.darwin.linux-builder = {
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/linux-builder";
      description = "Directory to store the linux builder state";
    };

    logPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/log/linux-builder.log";
      description = "Path to store the linux builder log";
    };

    hostPort = lib.mkOption {
      type = lib.types.int;
      default = 31022;
      description = "Port to use for the local builder";
    };

    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of jobs to run in parallel on the local builder";
    };

    speedFactor = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Speed factor to use for the local builder";
    };
  };

  config = {
    programs.ssh.knownHosts = {
      "linux-builder.localhost" = {
        hostNames = [ "linux-builder.localhost" ];
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb";
      };
    };

    environment.etc."ssh/ssh_config.d/builder-localhost".text = ''
      Host linux-builder.localhost
        User builder
        HostName 127.0.0.1
        Port ${toString cfg.darwin.linux-builder.hostPort}
        IdentityFile /etc/nix/builder_ed25519
    '';

    nix = {
      distributedBuilds = true;
      buildMachines = [{
        inherit (cfg.darwin.linux-builder) maxJobs speedFactor;
        hostName = "linux-builder.localhost";
        system = linuxSystem;
        supportedFeatures = [ "kvm" "benchmark" "big-parallel" "nixos-test" ];
      }];
    };

    launchd.daemons.linux-builder = {
      command = "${runLinuxBuilderScript}/bin/run-linux-builder";
      path = with pkgs; [ "/usr/bin" coreutils nix ];
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = cfg.darwin.linux-builder.logPath;
        StandardErrorPath = cfg.darwin.linux-builder.logPath;
      };
    };
  };
}
