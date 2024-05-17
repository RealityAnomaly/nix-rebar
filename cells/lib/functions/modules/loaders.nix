{ root, inputs, cell, lib, }:
let
  inherit (inputs) haumea;
  inherit (inputs.nixt.lib) nixt;
  inherit (root) mapFlattenAttrs;
  inherit (root.modules.utils) applyModuleArgs;

  loadFunctions =
    import ./_utils/loadFunctions.nix { inherit inputs cell lib; };
  nixNoTests = import ./../haumea/matchers/nixNoTests.nix { inherit lib; };
in rec {
  __export = {
    inherit loadConfigurations loadFunctions loadModules loadModules' loadShims
      loadTests loadUserSubcell;
  };

  /* *
     Load classical Nix configurations from a directory using Haumea.
     The difference between this function and `loadModules` is that it uses the `liftDefault` transformer.

     Example:
       loadConfigurations ./configurations inputs
       => { core = { nix = { default = { ... }; }; }; }

     Type:
       loadConfigurations :: Path -> AttrSet -> AttrSet
  */
  loadConfigurations = src: _inputs:
    loadModules' src _inputs {
      transformer = haumea.lib.transformers.liftDefault;
    };

  /* *
     Load classical Nix modules from a directory using Haumea.

     Example:
       loadModules ./modules inputs
       => { core = { nix = { default = { ... }; }; }; }

     Type:
       loadModules :: Path -> AttrSet -> AttrSet
  */
  loadModules = src: _inputs: loadModules' src _inputs { };

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
  loadModules' = src: _inputs: args:
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
      loader = [ (root.haumea.matchers.nixNoTests pathLoader) ];
      inputs = { inherit lib; } // _inputs;
    } // args);

  loadShims = src: _inputs:
    let
      suffix = "/default.shim.nix";

      imports = let
        files = builtins.readDir src;
        p = _n: v: v == "directory";
      in lib.filterAttrs p files;

      f = n: _:
        let
          path = "${src}/${n}";
          full = "${path}${suffix}";
        in if builtins.pathExists full then import full _inputs else null;
    in lib.filterAttrs (_: v: v != null) (lib.mapAttrs f imports);

  loadTests = prefix: src: _inputs:
    let
      tree = haumea.lib.load {
        inherit src;
        loader = [
          (haumea.lib.matchers.extension "spec.nix" haumea.lib.loaders.path)
        ];
        transformer = [ haumea.lib.transformers.liftDefault ];
      };
    in mapFlattenAttrs (_cursor: path:
      let cursor = [ prefix ] ++ _cursor;
      in lib.nameValuePair
      (lib.removeSuffix ".spec" (lib.concatStringsSep "__" cursor)) {
        inherit cursor path;
        value = import path ({
          inherit lib;
        } // _inputs // {
          # inputs.self is too noisy for 'check-augmented-cell-inputs'
          inputs = removeAttrs _inputs.inputs [ "self" ];
        });
      }) tree;

  /* *
     Loads a folder of user configurations as if they were Paisano cells.
     This is useful for loading user configurations in a similar way to how cells are loaded.

     Example:
       loadUserSubcell ./users inputs

     Type:
       loadUserSubcell :: Path -> AttrSet -> AttrSet
  */
  loadUserSubcell = src: _inputs:
    let
      readDirShallow = dir: predicate:
        lib.mapAttrsToList (k: _: k)
        (lib.filterAttrs (_name: predicate) (builtins.readDir dir));
    in lib.fix (_all_user_cells:
      root.genAttrs' (readDirShallow src (t: t == "directory")) (user: {
        name = user;
        value = lib.fix (_user_cell:
          root.genAttrs' (readDirShallow "${src}/${user}" (t: t == "regular"))
          (type: {
            name = lib.removeSuffix ".nix" type;
            value = import "${src}/${user}/${type}" (_inputs // {
              inherit user;
              cell = _user_cell // {
                __cr = _inputs.cell.__cr ++ [ user type ];
              };
            });
          }));
      }));

}
