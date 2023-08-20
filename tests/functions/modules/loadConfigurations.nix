{ inputs, cell, }:
let inherit (inputs.cells.lib.functions.modules) loadConfigurations;
in { expr = loadConfigurations ./_data/modules { test = "123"; }; }
