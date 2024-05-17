# boilerplate::loader::module_generic
_inputs@{ cell, inputs, }:
let inherit (inputs.cells.lib.functions) loadModules;
in loadModules ./commonModules _inputs
