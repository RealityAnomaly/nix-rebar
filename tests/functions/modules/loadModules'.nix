{ inputs, cell, }:
let inherit (inputs.cells.lib.functions.modules) loadModules';
in {
  expr = {
    default = loadModules' ./_data/modules { test = "123"; } { };
    metadata = loadModules' ./_data/modules {
      test = "123";
      cell.__cr = [ "foo" "123" ];
      inputs.self.outPath = "/foo/bar";
    } { };
  };
}
