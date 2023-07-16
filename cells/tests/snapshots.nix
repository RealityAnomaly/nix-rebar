let
  inherit (inputs) namaka self;
  inputs' = builtins.removeAttrs inputs [ "self" ];
in {
  default = {
    meta.description = "Snapshot test suite via Namaka";
    check = namaka.lib.load {
      src = self + /tests;
      inputs = inputs' //
        # inputs.self is too noisy for 'check-augmented-cell-inputs'
        {
          inputs = inputs';
        };
    };
  };
}
