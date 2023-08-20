/* *
   Load classical Nix modules from a directory using Haumea.
   Accepts the `args` parameter to pass to Haumea's `load` function.

   Example:
     loadModules' ./modules inputs {
       transformer = haumea.lib.transformers.liftDefault;
     }
     => { core = { nix = { default = { ... }; }; }; }

   Type:
     loadModules' :: Path -> AttrSet -> AttrSet -> AttrSet
*/
{ root, inputs, cell, }:
let
  inherit (inputs) haumea nixpkgs;
  inherit (nixpkgs) lib;
  inherit (root.modules.utils) applyModuleArgs;
in src: _inputs: args:
let
  # strips the source path prefix & any .nix suffix from the path
  stripPath = path:
    let stripped = lib.removePrefix (toString src + "/") (toString path);
    in lib.removeSuffix ".nix" stripped;

  # the purpose of this pathLoader helper function is to inject a `inner` function
  # available on the nixos module level that can inject our `mutateModule` attribute
  pathLoader = inputs: path:
    let
      # create a unique key for this module to allow it to be deduplicated across flakes
      # becomes i.e. /nix/store/3x2hnjvm43r42spyb6kagpp21jki73wn-source#common/commonProfiles/core/nix/default
      subPath = lib.concatStringsSep "/"
        ((_inputs.cell.__cr or [ ]) ++ [ (stripPath path) ]);
      key = "${_inputs.inputs.self.outPath or "unknown"}#${subPath}";
      mutator = module:
        if lib.isAttrs module then
          module // {
            inherit key;
            _file = path;
          }
        else
          module;
      f = lib.toFunction (import path);
      fn = lib.pipe f [
        lib.functionArgs
        (lib.mapAttrs (name: _: inputs.${name}))
        f
      ];
    in if lib.isFunction fn then
      args: mutator (applyModuleArgs key fn args)
    else
      mutator fn;
in haumea.lib.load ({
  inherit src;
  loader = pathLoader;
  inputs = _inputs // { inherit lib; };
} // args)
