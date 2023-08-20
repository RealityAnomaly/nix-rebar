# copied from nix's lib/modules.nix
{ root, inputs, cell, }:
key: f:
args@{ config, options, lib, ... }:
let
  context = name:
    ''while evaluating the module argument `${name}' in "${key}":'';
  extraArgs = builtins.mapAttrs (name: _:
    builtins.addErrorContext (context name)
    (args.${name} or config._module.args.${name})) (lib.functionArgs f);
in f (args // extraArgs)
