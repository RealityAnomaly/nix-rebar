{ root, inputs, cell, }:
let
  inherit (inputs) nixpkgs nixos-stable;
  inherit (nixpkgs) lib;
in rec {
  mkColmenaMeta = evaled: {
    meta = {
      # While it's not great to hard-code the system, for now, this option is
      # required, so we use the sane default nixpkgs for `x86_64-linux`.
      # In the end, this setting gets overridden on a per-host basis.
      nixpkgs = nixos-stable.legacyPackages."x86_64-linux";
      description = "nix-rebar colmena hive";
      nodeNixpkgs = lib.mapAttrs (_: v: v.pkgs) evaled;
      nodeSpecialArgs = lib.mapAttrs (_: v: v._module.specialArgs) evaled;
    };
  };
}
