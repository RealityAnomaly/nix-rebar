/* *
   Loads a folder of user configurations as if they were Paisano cells.
   This is useful for loading user configurations in a similar way to how cells are loaded.

   Example:
     loadUserSubcell ./users inputs

   Type:
     loadUserSubcell :: Path -> AttrSet -> AttrSet
*/
{ root, inputs, cell, }:
let inherit (inputs.nixpkgs) lib;
in src: _inputs:
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
          cell = _user_cell // { __cr = _inputs.cell.__cr ++ [ user type ]; };
        });
      }));
  }))
