{ inputs, cell, }:
let inherit (inputs.cells.lib.functions.modules) loadUserSubcell;
in {
  expr = loadUserSubcell ./_data/users {
    cell.__cr = [ "foo2" "bar1" ];
    inputs = { };
  };
}
