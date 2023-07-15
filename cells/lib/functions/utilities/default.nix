{ root, inputs, cell, }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
in {
  inherit (root.utilities.attrs) mapFilterAttrs genAttrs' attrCount defaultAttrs defaultSetAttrs enumAttrs imapAttrsToList
    recursiveMerge recursiveMergeAttrsWith recursiveMergeAttrsWithNames;
  inherit (root.utilities.lists) filterListNonEmpty;
  inherit (root.utilities.misc) optionalPath optionalPathImport isIPv6 tryEval';
}
