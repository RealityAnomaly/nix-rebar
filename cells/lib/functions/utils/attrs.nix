{ root, inputs, cell, lib, }: rec {
  __export = {
    inherit concatMapAttrsWith countAttrs defaultAttrs defaultSetAttrs enumAttrs
      extractPair extractFilterAttrs flattenAttrs genAttrs' imapAttrsToList
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
  concatMapAttrsWith = merge: f:
    lib.flip lib.pipe [
      (lib.mapAttrs f)
      builtins.attrValues
      (builtins.foldl' merge { })
    ];

  /* *
     Count the number of attributes in a set
  */
  countAttrs = set: lib.length (builtins.attrNames set);

  /* *
     TODO: documentation
  */
  defaultAttrs = attrs: default: f: if attrs != null then f attrs else default;

  /* *
     Given a list of attribute sets, merges the keys specified by "names" from "defaults" into them if they do not exist
  */
  defaultSetAttrs = sets: names: defaults:
    (lib.mapAttrs' (n: v:
      lib.nameValuePair n (v // lib.genAttrs names (name:
        (if builtins.hasAttr name v then v.${name} else defaults.${name}))))
      sets);

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
      filtered = lib.filterAttrs predicate attrs;
      name = lib.head (builtins.attrNames filtered);
    in {
      inherit name;
      value = attrs.${name};
    };

  /* *
     Extract attributes from a list of attribute sets while excluding the specified attributes
  */
  extractFilterAttrs = exclude: attrs:
    lib.zipAttrs (map (lib.filterAttrs (n: _: !builtins.elem n exclude)) attrs);

  /* *
     Flattens an attribute set by concatenating the paths of all its leaves
  */
  flattenAttrs = sep: attrs:
    let
      f = cursor: value:
        if builtins.isAttrs value then
          lib.flatten (lib.mapAttrsToList (k: f (cursor ++ [ k ])) value)
        else {
          "${lib.concatStringsSep sep cursor}" = value;
        };
    in recursiveMerge (f [ ] attrs);

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
      f = lib.zipAttrsWith (n: values:
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
