{ inputs, cell }:
_final: prev: {
  nixVersions = prev.nixVersions.extend (_nixFinal: nixPrev: {
    nix_2_13 = nixPrev.nix_2_13.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ../pkgs/tools/package-management/nix/0001-Fix-follow-path-checking-at-depths-greater-than-2.patch
      ];
    });
  });
}
