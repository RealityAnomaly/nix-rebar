{ inputs, cell, ... }:
let
  inherit (inputs) self;
  inherit (inputs.cells.lib.functions.providers) namaka;
in {
  default = {
    meta.description = "Snapshot test suite via Namaka";
    check = namaka.load {
      src = self + /tests;
      inputs = {
        inherit cell;

        # inputs.self is too noisy for 'check-augmented-cell-inputs'
        inputs = removeAttrs inputs [ "self" ];
      };
    };
  };
}
