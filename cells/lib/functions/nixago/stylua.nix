{ inputs, cell, }:
inputs.std.lib.dev.mkNixago {
  output = "stylua.toml";
  format = "toml";
  data = { };
  packages = [ inputs.nixpkgs.stylua ];
}
