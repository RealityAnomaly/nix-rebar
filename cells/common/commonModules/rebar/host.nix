{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }:
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

    overlays = let
      overlayType = lib.mkOptionType {
        name = "nixpkgs-overlay";
        description = "nixpkgs overlay";
        check = lib.isFunction;
        merge = lib.mergeOneOption;
      };
    in lib.mkOption {
      type = lib.types.listOf overlayType;
      default = [ ];
      description = "Overlays to add to the host system";
    };

    system = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    bee = {
      inherit (cfg.host) system;
      inherit (inputs) home;

      darwin = lib.mkIf parsedSystem.isDarwin inputs.darwin;
      pkgs = import inputs.nixos-stable {
        inherit (cfg.host) overlays system;
        config.allowUnfree = true;
      };
    };
  };
}
