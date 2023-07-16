{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  options.rebar.host = {
    wsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description =
        "Whether the host is running under Windows Subsystem for Linux";
    };
  };
}
