{ root, }: {
  inherit (root.utilities.attrs)
    mapFilterAttrs genAttrs' countAttrs defaultAttrs defaultSetAttrs enumAttrs
    extractPair imapAttrsToList recursiveMerge recursiveMergeAttrsWith
    recursiveMergeAttrsWithNames;
  inherit (root.utilities.lists) filterListNonEmpty;
  inherit (root.utilities.misc) optionalPath optionalPathImport isIPv6 tryEval';
}
