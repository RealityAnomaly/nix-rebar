{ inputs, cell, }:
inputs.std.lib.dev.mkNixago {
  output = "namaka.toml";
  format = "toml";
  data = { };
  packages = [ inputs.nixpkgs-unstable.legacyPackages.namaka ];
}
