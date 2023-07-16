{ inputs, cell, }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.lib.functions.devshells) pkgWithCategory;
  inherit (nixpkgs.stdenv) isLinux;

  l = inputs.nixpkgs.lib // builtins;
  home-manager = inputs.home.packages.default;

  commonCommands = let
    maintenance = pkgWithCategory "maintenance";
    utils = pkgWithCategory "utils";
  in [
    (utils inputs.ragenix.packages.ragenix)
    (utils nixpkgs.cachix)
    (utils home-manager)
    (utils nixpkgs.just)
    (utils nixpkgs.nix-diff)
    (utils nixpkgs.nix-tree)
    (utils nixpkgs.nvd)

    (maintenance nixpkgs.deadnix)
    (maintenance nixpkgs.nixfmt)
    (maintenance nixpkgs.nodePackages.prettier)
    (maintenance nixpkgs.statix)
  ];

  linuxCommands = l.optionals isLinux [
    # (cobalt inputs.deploy-rs.packages.deploy-rs)
    # (cobalt inputs.nixos-generators.packages.nixos-generate)
  ];
in {
  default = _: {
    commands = commonCommands ++ linuxCommands;

    env = [
      {
        name = "REBAR_SYS_DRV";
        eval = "/nix/var/nix/profiles/system";
      }
      {
        name = "REBAR_HOME_DRV";
        eval = "/nix/var/nix/profiles/per-user/$USER/home-manager";
      }
    ];

    packages = with nixpkgs; [ cachix shellcheck ];
  };
}
