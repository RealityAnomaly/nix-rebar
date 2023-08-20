# if path exists, evaluate expr with it, otherwise return other
{ root, inputs, cell, }:
let inherit (builtins) pathExists;
in path: expr: other: if pathExists path then expr path else other
