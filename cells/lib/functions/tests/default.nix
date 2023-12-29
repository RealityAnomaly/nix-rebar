{ root, inputs, cell, lib, ... }:
let
  inherit (inputs) self;
  inherit (inputs.nixt.lib) nixt;
  inherit (inputs.cells.lib.functions.providers) namaka;
in {
  eq = expr: expected: { inherit expr expected; };

  loadNamaka = tests:
    namaka.load {
      state = self + /state/namaka;
      tests = lib.mapAttrs (_n: v: v.value.snapshot)
        (lib.filterAttrs (_n: v: v.value ? "snapshot") tests);
    };

  loadNixt = tests:
    let
      convertCases =
        lib.mapAttrs (_: lib.mapAttrs (_k: v: v.expr == v.expected));
    in nixt.grow {
      blocks = lib.mapAttrsToList (_: tests:
        nixt.block' (/. + tests.path) (convertCases tests.value.unit))
        (lib.filterAttrs (_: v: v.value ? "unit") tests);
    };

  loadNixpkgs = tests:
    lib.mapAttrsToList (_: tests:
      lib.mapAttrs
      (_: cases: lib.debug.runTests (cases // { tests = lib.attrNames cases; }))
      tests.value.unit) (lib.filterAttrs (_: v: v.value ? "unit") tests);
}
