# boilerplate::loader::module_generic
_inputs@{ cell, inputs, }:
let inherit (inputs.nix-rebar.functions.modules) loadModules;
in loadModules ./homeModules _inputs
