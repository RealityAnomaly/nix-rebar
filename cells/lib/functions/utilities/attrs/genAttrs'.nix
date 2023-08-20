# Generate an attribute set by mapping a function over a list of values.
{ root, inputs, cell, }:
let inherit (builtins) listToAttrs;
in values: f: listToAttrs (map f values)
