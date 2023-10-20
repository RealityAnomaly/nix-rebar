# boilerplate::loader::test_generic
_inputs@{ cell, inputs, }:
let inherit (inputs.cells.lib.functions.modules) loadTests;
in loadTests "functions" ./functions _inputs
