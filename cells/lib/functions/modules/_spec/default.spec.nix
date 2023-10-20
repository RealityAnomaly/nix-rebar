{ inputs, cell, ... }: let
  inherit (inputs.cells.lib.functions.modules) extractSuites loadConfigurations
    loadModules loadModules' loadUserSubcell mkConfiguration;
in {
  snapshot = {
    extractSuites.expr = extractSuites {
      system = "x86_64-linux";
      types = [{ name = "core"; }];
    } [ ] {
      _system_core = "test1";
      _system_workstation = "test2";
      _system_foobar = "test3";
    };
    loadConfigurations.expr = loadConfigurations ./modules { test = "123"; };
    loadModules.expr = loadModules ./modules { test = "123"; };
    loadModules'.expr = {
      default = loadModules' ./modules { test = "123"; } { };
      metadata = loadModules' ./modules {
        test = "123";
        cell.__cr = [ "foo" "123" ];
        inputs.self.outPath = "/foo/bar";
      } { };
    };
    loadUserSubcell.expr = loadUserSubcell ./modules/users {
      cell.__cr = [ "foo2" "bar1" ];
      inputs = { };
    };
    mkConfiguration.expr = mkConfiguration { } {
      system = "aarch64-darwin";
      types = [ ];
      platformStateVersion = 4;
    } { networking.computerName = "foobar"; };
  };
}
