# boilerplate::loader::functions_vendor
_inputs@{ cell, inputs, }:
let inherit (inputs.cells.lib.functions.modules) loadShims;
in loadShims ./vendor _inputs
