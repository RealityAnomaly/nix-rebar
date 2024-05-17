{ inputs, cell, lib, ... }:
let sub = cell.functions.modules.loaders;
in {
  snapshot = {
    loadConfigurations.expr =
      sub.loadConfigurations ./_spec/modules { test = "123"; };
    loadModules.expr = sub.loadModules ./_spec/modules { test = "123"; };
    loadModules'.expr = {
      default = sub.loadModules' ./_spec/modules { test = "123"; } { };
      metadata = sub.loadModules' ./_spec/modules {
        test = "123";
        cell.__cr = [ "foo" "123" ];
        inputs.self.outPath = "/foo/bar";
      } { };
    };
    loadUserSubcell.expr = sub.loadUserSubcell ./_spec/users {
      cell.__cr = [ "foo2" "bar1" ];
      inputs = { };
    };
  };
}
