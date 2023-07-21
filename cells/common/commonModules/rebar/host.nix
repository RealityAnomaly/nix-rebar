{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
let
  cfg = config.rebar;
  parsedSystem = lib.systems.elaborate cfg.host.system;
in {
  options.rebar.host = {
    wsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description =
        "Whether the host is running under Windows Subsystem for Linux";
    };

    types = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Attrs of system types from which this system inherits";
    };

    system = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    #_args.system = cfg.host.system;

    bee = {
      inherit (cfg.host) system;
      inherit (inputs) home;

      darwin = lib.mkIf parsedSystem.isDarwin inputs.darwin;
      pkgs = import inputs.nixos-stable {
        inherit (cfg.host) system;
        config.allowUnfree = true;
      };
    };
  };
}
