# if path exists, import it, otherwise return other
{ root, inputs, cell, }:
let inherit (root.utilities.misc) optionalPath;
in path: optionalPath path import
