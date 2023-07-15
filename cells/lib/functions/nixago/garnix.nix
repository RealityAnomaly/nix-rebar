{ inputs, cell, }:
inputs.std.lib.dev.mkNixago {
  output = "garnix.yaml";
  data = { };
  format = "yaml";
}
