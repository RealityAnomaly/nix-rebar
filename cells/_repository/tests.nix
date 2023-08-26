{ inputs, cell, ... }:
let
  inherit (inputs) cells nixpkgs;
  inherit (inputs.nixt.lib) nixt;
  inherit (nixpkgs) lib;
  inherit (cells.lib.functions.modules) loadTests;

  testsFromPaths = paths:
    lib.flatten (map (src: loadTests src { inherit inputs cell; }) paths);
in nixt.grow { blocks = testsFromPaths [ ./../lib/functions ]; }
