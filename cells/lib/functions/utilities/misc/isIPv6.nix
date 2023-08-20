# determines whether a given address is IPv6 or not
{ root, inputs, cell, }:
let inherit (builtins) match;
in str: match ".*:.*" str != null
