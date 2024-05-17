# boilerplate::loader::configuration_generic
_inputs@{ cell, inputs, }:
let inherit (inputs.cells.lib.functions) loadConfigurations;
in loadConfigurations ./diskoConfigurations _inputs
