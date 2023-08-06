{ root, inputs, cell, }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;

  inherit (builtins) attrNames isAttrs isList listToAttrs hasAttr;
  inherit (lib)
    all head tail last unique length nameValuePair genList genAttrs zipAttrsWith
    zipAttrsWithNames filterAttrs mapAttrs' concatLists concatMap foldl' elemAt;
in rec {
  # mapFilterAttrs ::
  #   (name -> value -> bool )
  #   (name -> value -> { name = any; value = any; })
  #   attrs
  mapFilterAttrs = seive: f: attrs: filterAttrs seive (mapAttrs' f attrs);

  # Generate an attribute set by mapping a function over a list of values.
  genAttrs' = values: f: listToAttrs (map f values);

  # counts the number of attributes in a set
  attrCount = set: length (attrNames set);

  defaultAttrs = attrs: default: f: if attrs != null then f attrs else default;

  # given a list of attribute sets, merges the keys specified by "names" from "defaults" into them if they do not exist
  defaultSetAttrs = sets: names: defaults:
    (mapAttrs' (n: v:
      nameValuePair n (v // genAttrs names
        (name: (if hasAttr name v then v.${name} else defaults.${name}))))
      sets);

  /* Convert a list of strings to an attrset where the keys match the values.

     Example:
       enumAttrs ["foo" "bar"]
       => {foo = "foo"; bar = "bar";}
  */
  enumAttrs = enum: lib.genAttrs enum (s: s);

  /* *
     Extracts a single name-value attribute pair from the specified attribute set using the predicate
  */
  extractPair = predicate: attrs:
    let
      filtered = filterAttrs predicate attrs;
      name = lib.head (lib.attrNames filtered);
    in {
      inherit name;
      value = attrs.${name};
    };

  # maps attrs to list with an extra i iteration parameter
  imapAttrsToList = f: set:
    (let keys = attrNames set;
    in genList (n:
      let
        key = elemAt keys n;
        value = set.${key};
      in f n key value) (length keys));

  # Recursively merges attribute sets **and** lists
  recursiveMerge = attrList:
    let
      f = _attrPath:
        zipAttrsWith (n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (concatLists values)
          else if all isAttrs values then
            f [ n ] values
          else
            last values);
    in f [ ] attrList;

  recursiveMergeAttrsWithNames = names: f:
    zipAttrsWithNames names (_name: foldl' f { });

  recursiveMergeAttrsWith = f: sets:
    recursiveMergeAttrsWithNames (concatMap attrNames sets) f sets;
}
