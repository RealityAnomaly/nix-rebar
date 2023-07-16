# boilerplate::loader::configuration_generic
_inputs@{ cell, inputs, }:
let inherit (inputs.cells.lib.functions.modules) loadConfigurations;
in loadConfigurations ./diskoConfigurations _inputs
