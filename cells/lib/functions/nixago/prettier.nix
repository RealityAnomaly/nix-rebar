{ inputs, cell, }:
let pkgs' = inputs.nixpkgs;
in inputs.std.lib.dev.mkNixago {
  output = ".prettierrc.json";
  data = { };
  format = "json";
  packages = [ pkgs'.nodePackages.prettier ];
}
