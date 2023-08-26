{ root, inputs, cell, lib, }: rec {
  __export = { inherit filterListNonEmpty; };

  # filters out empty strings and null objects from a list
  filterListNonEmpty = lib.filter (x: (x != "" && x != null));
}
