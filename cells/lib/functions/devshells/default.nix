{ inputs, cell, ... }: rec {
  pkgWithCategory = category: package:
    withCategory category { inherit package; };
  withCategory = category: attrs: attrs // { inherit category; };
}
