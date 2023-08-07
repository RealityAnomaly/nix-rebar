{ root, inputs, cell, }:
let
  inherit (inputs) haumea nixpkgs;
  inherit (nixpkgs) lib;

  # copied from nix's lib/modules.nix
  applyModuleArgs = key: f:
    args@{ config, options, lib, ... }:
    let
      context = name:
        ''while evaluating the module argument `${name}' in "${key}":'';
      extraArgs = builtins.mapAttrs (name: _:
        builtins.addErrorContext (context name)
        (args.${name} or config._module.args.${name})) (lib.functionArgs f);
    in f (args // extraArgs);
in rec {
  /**
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
          cellSuffix = lib.concatStringsSep "/" _inputs.cell.__cr;
          key =
            "${_inputs.inputs.self.outPath}#${cellSuffix}/${stripPath path}";
          mutator = module: module // { inherit key; };
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
    } // args);

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
      root.utilities.genAttrs' (readDirShallow src (t: t == "directory"))
      (user: {
        name = user;
        value = lib.fix (_user_cell:
          root.utilities.genAttrs'
          (readDirShallow "${src}/${user}" (t: t == "regular")) (type: {
            name = lib.removeSuffix ".nix" type;
            value = import "${src}/${user}/${type}" (_inputs // {
              inherit user;
              cell = _user_cell // {
                __cr = _inputs.cell.__cr ++ [ user type ];
              };
            });
          }));
      }));

  /* *
     Given suites, extract which suites should be loaded for a given system.

     Example:
       extractSuites' = { inherit system types; };
       extractSuites' [ ] cells.common.commonSuites
       => [ <MODULE> <MODULE> <MODULE> ... ]

     Type:
       extractSuites :: AttrSet -> [String] -> AttrSet
  */
  extractSuites = { system, types, ... }:
    path: root':
    let
      inherit (root.systems) systemTypes;
      parsedSystem = lib.systems.elaborate system;

      # eval the "predicate" attribute if it exists
      autoTypes = lib.mapAttrsToList (n: _: n) (lib.filterAttrs (_: v:
        let predicate = v.predicate or (_: false);
        in predicate parsedSystem) systemTypes);

      filteredTypes = lib.unique ((map (t: t.name) (types ++ [
        systemTypes.core # default system type
      ])) ++ autoTypes);
    in lib.unique (lib.remove null
      (map (type: lib.attrByPath (path ++ [ "_system_${type}" ]) null root')
        filteredTypes));

  /* *
     Preprocessor for Nix configurations to automatically extract suites based on the system type.

     Example:
       mkConfiguration inputs {
         system = "aarch64-darwin";
         types = [ systemTypes.workstation ];
         platformStateVersion = 4;
       } {
         networking.computerName = "A MacBook Pro";
       };
       => { imports = [ ... ]; rebar = { ... }; system = { ... }; }
  */
  mkConfiguration = inputs:
    { system, types ? [ ], commonModules ? [ ], platformModules ? [ ]
    , platformStateVersion, homeModules ? [ ], }:
    defaultModule:
    let
      inherit (inputs) cells;

      # parse the system string provided and extract its type
      parsedSystem = lib.systems.elaborate system;
      extractSuites' = extractSuites { inherit system types; };

      commonSuites = extractSuites' [ ] cells.common.commonSuites;
      platformSuites = let
        platform = if parsedSystem.isDarwin then
          cells.darwin.darwinSuites
        else if parsedSystem.isLinux then
          cells.nixos.nixosSuites
        else
          throw "Unsupported system type";
      in extractSuites' [ ] platform;
      homeSuites = extractSuites' [ ] cells.home.homeSuites;
    in {
      imports = commonModules ++ commonSuites ++ platformModules
        ++ platformSuites ++ [ defaultModule ];

      rebar = {
        inherit inputs;

        enable = true;
        host = { inherit system types; };
      };

      home-manager.sharedModules = homeModules ++ homeSuites;
      system = { stateVersion = platformStateVersion; };
    };
}
