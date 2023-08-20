{ inputs, cell, }:
let inherit (inputs.cells.lib.functions.modules) loadModules;
in { expr = loadModules ./_data/modules { test = "123"; }; }
