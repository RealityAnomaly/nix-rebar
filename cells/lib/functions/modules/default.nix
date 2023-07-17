{ root, inputs, cell, }:
let
  inherit (inputs) haumea nixpkgs;
  inherit (nixpkgs) lib;
in rec {
  loadModules' = src: _inputs: args:
    haumea.lib.load ({
      inherit src;
      inputs = _inputs // { inherit lib; };
    } // args);

  # standardised method of loading Nix eval system's profiles and modules using Haumea
  loadModules = src: _inputs: loadModules' src _inputs { };
  loadConfigurations = src: _inputs:
    loadModules' src _inputs {
      transformer = haumea.lib.transformers.liftDefault;
    };

  # hacky way of loading users as if they were cells at the top-level
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
              cell = _user_cell;
            });
          }));
      }));

  mkConfiguration = inputs:
    { system, user, types ? [ ], commonModules ? [ ], platformModules ? [ ]
    , platformStateVersion ? 4, homeModules ? [ ], homeStateVersion ? "23.05",
    }:
    let
      inherit (inputs) cells;
      inherit (root.systems) systemTypes;

      # parse the system string provided and extract its type
      parsedSystem = lib.systems.elaborate system;

      # extract all our necessary suites
      extractSuites = path: root:
        let
          # eval the "predicate" attribute if it exists
          autoTypes = lib.mapAttrsToList (n: _: n) (lib.filterAttrs (_: v:
            let predicate = v.predicate or (_: false);
            in predicate parsedSystem) systemTypes);

          filteredTypes = lib.unique ((map (t: t.name) (types ++ [
            systemTypes.core # default system type
          ])) ++ autoTypes);
        in lib.unique (lib.remove null
          (map (type: lib.attrByPath (path ++ [ "_system_${type}" ]) null root)
            filteredTypes));

      commonSuites = extractSuites [ ] cells.common.commonSuites;
      platformSuites = let
        platform = if parsedSystem.isDarwin then
          cells.darwin.darwinSuites
        else if parsedSystem.isLinux then
          cells.nixos.nixosSuites
        else
          throw "Unsupported system type";
      in extractSuites [ ] platform;
      homeSuites = extractSuites [ ] cells.home.homeSuites;

      _user = {
        homeSuites = extractSuites [ ] cells.common.users.${user}.homeSuites;
      };
    in {
      imports = commonModules ++ commonSuites ++ platformModules
        ++ platformSuites;

      rebar = {
        inherit inputs;

        enable = true;
        host = { inherit system; };
        users.${user} = {
          enable = true;
          privileged = true;
        };
      };

      home-manager.users.${user} = _: {
        imports = homeModules ++ homeSuites ++ _user.homeSuites;
        home.stateVersion = homeStateVersion;
      };

      system = { stateVersion = platformStateVersion; };
    };

  mkSuite = { auto ? null }: configuration: configuration;
}
