{ root, inputs, cell, lib, }: rec {
  __export = { inherit extractSuites; };

  /* *
     Given suites, extract which suites should be loaded for a given system.

     Example:
       extractSuites' = extractSuites { inherit system types; };
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
}
