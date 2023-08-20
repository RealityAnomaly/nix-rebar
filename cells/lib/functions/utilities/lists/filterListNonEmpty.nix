# filters out empty strings and null objects from a list
{ root, inputs, cell, }:
let inherit (inputs.nixpkgs.lib) filter;
in filter (x: (x != "" && x != null))
