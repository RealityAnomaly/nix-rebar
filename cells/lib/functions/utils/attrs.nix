{ root, inputs, cell, lib, }: let
  inherit (inputs) yants;
in rec {
  __export = {
    inherit concatMapAttrsWith countAttrs defaultAttrs enumAttrs
      extractPair extractFilterAttrs mapFlattenAttrs flattenAttrs genAttrs' imapAttrsToList
      mapFilterAttrs recursiveMerge recursiveMergeAttrsWith
      recursiveMergeAttrsWithNames;
  };

  /* *
     Map each attribute in the given set into
     a list of attributes and subsequently merge them into
     a new attribute set with the specified mergeFun.

     Type: ({ ... } -> { ... } -> { ... }) -> (String -> a -> { ... }) -> { ... } -> { ... }

     Example:
       concatMapAttrsWith (mergeAttrsButConcatOn "mykey")
         (name: value: {
           ${name} = value;
           ${key} = value ++ value;
         })
         { x = "a"; y = "b"; }
       => { x = "a"; y = "b"; mykey = [ "aa" "bb"]; }
  */
  concatMapAttrsWith =
    yants.defun (with yants; [function function (attrs any) (attrs any)]) (
      merge: f: lib.flip lib.pipe [
        (lib.mapAttrs f)
        builtins.attrValues
        (builtins.foldl' merge { })
      ]
    );

  /* *
     Count the number of attributes in a set
  */
  countAttrs = set: lib.length (builtins.attrNames set);

  /* *
     TODO: documentation
  */
  defaultAttrs =
    yants.defun (with yants; [(either (attrs any) any) (attrs any) function (attrs any)]) (
      attrs: default: f: if attrs != null then f attrs else default
    );

  /* *
     Convert a list of strings to an attrset where the keys match the values.
     Example:
       enumAttrs ["foo" "bar"]
       => {foo = "foo"; bar = "bar";}
  */
  enumAttrs = enum: lib.genAttrs enum lib.id;

  /* *
     Extract a single name-value attribute pair from the specified attribute set using the predicate
  */
  extractPair = predicate: attrs:
    let
      found = builtins.attrNames (lib.filterAttrs predicate attrs);
    in if ((builtins.length found) == 0) then null else let
      name = lib.head found;
    in {
      inherit name;
      value = attrs.${name};
    };

  /* *
     Extract attributes from a list of attribute sets while excluding the specified attributes
  */
  extractFilterAttrs = exclude: attrs:
    lib.zipAttrs (map (lib.filterAttrs (n: _: !(builtins.elem n exclude))) attrs);
  
  mapFlattenAttrs = fn: attrs:
    let
      f = cursor: value:
        if builtins.isAttrs value then
          lib.flatten (lib.mapAttrsToList (k: f (cursor ++ [ k ])) value)
        else let
          pair = fn cursor value;
        in {
          ${pair.name} = pair.value;
        };
    in recursiveMerge (f [ ] attrs);

  /* *
     Flattens an attribute set by concatenating the paths of all its leaves
  */
  flattenAttrs = sep: mapFlattenAttrs (
    cursor: lib.nameValuePair (lib.concatStringsSep sep cursor)
  );

  /* *
     Generate an attribute set by mapping a function over a list of values.
  */
  genAttrs' = values: f: builtins.listToAttrs (map f values);

  /* *
     Maps attrs to list with an extra i iteration parameter
  */
  imapAttrsToList = f: set:
    let keys = builtins.attrNames set;
    in lib.genList (n:
      let
        key = lib.elemAt keys n;
        value = set.${key};
      in f n key value) (lib.length keys);

  /* *
     TODO: documentation
  */
  mapFilterAttrs = seive: f: attrs:
    lib.filterAttrs seive (lib.mapAttrs' f attrs);

  /* *
     Recursively merges attribute sets and respects lists
  */
  recursiveMerge = attrList:
    let
      f = builtins.zipAttrsWith (n: values:
        if lib.tail values == [ ] then
          lib.head values
        else if lib.all builtins.isList values then
          lib.unique (lib.concatLists values)
        else if lib.all builtins.isAttrs values then
          f [ n ] values
        else
          lib.last values);
    in f attrList;

  /* *
     TODO: documentation
  */
  recursiveMergeAttrsWith = f: sets:
    recursiveMergeAttrsWithNames (lib.concatMap builtins.attrNames sets) f sets;

  /* *
     TODO: documentation
  */
  recursiveMergeAttrsWithNames = names: f:
    lib.zipAttrsWithNames names (_name: lib.foldl' f { });
}
