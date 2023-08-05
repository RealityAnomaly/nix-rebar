{ inputs, cell, }:
let
  inherit (inputs) cells nixpkgs std;
  inherit (nixpkgs) lib;

  inherit (cells.lib.functions) nixago;
  inherit (std.lib.dev) mkNixago;
in {
  # commitlint = lib.dev.nixago.commitlint {
  #   data = import ./config/commitlint.nix;
  # };
  editorconfig = mkNixago std.lib.cfg.editorconfig {
    data = import ./config/editorconfig.nix;
  };
  lefthook =
    mkNixago std.lib.cfg.lefthook { data = import ./config/lefthook.nix; };
  namaka = nixago.namaka { data = import ./config/namaka.nix; };
  prettier = nixago.prettier { data = import ./config/prettier.nix; };
  statix = nixago.statix { data = import ./config/statix.nix; };
  stylua = nixago.stylua { data = import ./config/stylua.nix; };
  treefmt = mkNixago std.lib.cfg.treefmt {
    data = import ./config/treefmt.nix;
    packages = [
      nixpkgs.nodePackages.eslint
      nixpkgs.nodePackages.prettier-plugin-toml
      nixpkgs.shfmt
    ];
    devshell.startup.prettier-plugin-toml = lib.stringsWithDeps.noDepEntry ''
      export NODE_PATH=${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules''${NODE_PATH:+:''${NODE_PATH}}
    '';
  };
}
