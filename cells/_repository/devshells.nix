{ inputs, cell, ... }:
let
  inherit (inputs) cells std;
  inherit (std.lib.dev) mkShell;

  l = inputs.nixpkgs.lib // builtins;
  pkgs = inputs.nixpkgs;
in {
  # meta = {
  #   description = "foo";
  # };

  default = (mkShell (_: {
    name = "rebar";

    imports = [
      # Use Standard's TUI
      std.std.devshellProfiles.default
      cells.common.devshellProfiles.default
    ];

    # Which files do we want to write?
    nixago = l.mapAttrsToList (_: v: v { }) cell.config;

    # What do we want to include in the shell environment?
    packages = with pkgs; [ gh reuse ];
  })) // {
    meta.description = "Common devshell for rebar";
  };

  ci = mkShell (_: { name = "rebar-ci"; }) // {
    meta.description = "Functions used for continuous integration";
  };
}
