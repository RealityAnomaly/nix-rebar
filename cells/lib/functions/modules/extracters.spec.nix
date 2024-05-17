{ inputs, cell, lib, ... }:
let sub = cell.functions.modules.extracters;
in {
  snapshot = {
    extractSuites.expr = sub.extractSuites {
      system = "x86_64-linux";
      types = [{ name = "core"; }];
    } [ ] {
      _system_core = "test1";
      _system_workstation = "test2";
      _system_foobar = "test3";
    };
  };
}
