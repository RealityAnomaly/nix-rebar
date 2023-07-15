{ inputs, cell, }:
let pkgs' = inputs.nixpkgs;
in inputs.std.lib.dev.mkNixago {
  data = { };
  output = ".commitlintrc.json";
  format = "json";
  packages = [ pkgs'.commitlint ];
}
