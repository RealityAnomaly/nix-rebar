# boilerplate::loader::configuration_generic
_inputs@{ cell, inputs, }:
let inherit (inputs.nix-rebar.functions.modules) loadConfigurations;
in loadConfigurations ./diskoConfigurations _inputs
