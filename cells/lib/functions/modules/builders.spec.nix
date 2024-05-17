{ inputs, cell, lib, ... }:
let sub = cell.functions.modules.builders;
in {
  snapshot = {
    mkConfiguration.expr = sub.mkConfiguration { } {
      system = "aarch64-darwin";
      types = [ ];
      platformStateVersion = 4;
    } { networking.computerName = "foobar"; };
  };
}
