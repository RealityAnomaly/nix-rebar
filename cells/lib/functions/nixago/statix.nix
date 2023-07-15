{ inputs, cell, }:
inputs.std.lib.dev.mkNixago {
  output = "statix.toml";
  format = "toml";
  data = { };
  packages = [ inputs.nixpkgs.statix ];
}
