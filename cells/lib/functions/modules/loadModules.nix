/* *
   Load classical Nix modules from a directory using Haumea.

   Example:
     loadModules ./modules inputs
     => { core = { nix = { default = { ... }; }; }; }

   Type:
     loadModules :: Path -> AttrSet -> AttrSet
*/
{ root, inputs, cell, }:
let inherit (root.modules) loadModules';
in src: _inputs: loadModules' src _inputs { }
