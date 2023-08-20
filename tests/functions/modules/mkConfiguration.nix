{ inputs, cell, }:
let inherit (inputs.cells.lib.functions.modules) mkConfiguration;
in {
  expr = mkConfiguration { } {
    system = "aarch64-darwin";
    types = [ ];
    platformStateVersion = 4;
  } { networking.computerName = "foobar"; };
}
