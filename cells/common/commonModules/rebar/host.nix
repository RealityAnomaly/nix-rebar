{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
let cfg = config.rebar;
in {
  options.rebar.host = {
    wsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description =
        "Whether the host is running under Windows Subsystem for Linux";
    };

    system = lib.mkOption { type = lib.types.str; };
    darwin = lib.mkOption { type = lib.types.bool; };
  };

  config = lib.mkIf cfg.enable {
    bee = {
      inherit (cfg.host) system;
      inherit (inputs) home;

      darwin = lib.mkIf cfg.host.darwin inputs.darwin;
      pkgs = import inputs.nixos-stable {
        inherit (cfg.host) system;
        config.allowUnfree = true;
      };
    };
  };
}
