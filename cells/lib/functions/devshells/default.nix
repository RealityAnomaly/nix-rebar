{ inputs, cell, ... }: rec {
  pkgWithCategory = category: package: attrs:
    withCategory category ({ inherit package; } // attrs);
  withCategory = category: attrs: attrs // { inherit category; };

  pkgCategories = categories:
    builtins.listToAttrs (map (name: {
      inherit name;
      value = pkgWithCategory name;
    }) categories);
}
