{ inputs, cell, ... }:
let inherit (inputs.cells.lib.functions.tests) loadNamaka;
in {
  default = {
    meta.description = "Snapshot test suite via Namaka";
    check = loadNamaka inputs.cells.lib.tests;
  };
}
