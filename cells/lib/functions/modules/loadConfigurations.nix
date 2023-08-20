/* *
   Load classical Nix configurations from a directory using Haumea.
   The difference between this function and `loadModules` is that it uses the `liftDefault` transformer.

   Example:
     loadConfigurations ./configurations inputs
     => { core = { nix = { default = { ... }; }; }; }

   Type:
     loadConfigurations :: Path -> AttrSet -> AttrSet
*/
{ root, inputs, cell, }:
let
  inherit (inputs) haumea;
  inherit (root.modules) loadModules';
in src: _inputs:
loadModules' src _inputs { transformer = haumea.lib.transformers.liftDefault; }
