{ inputs, cell, ... }:
let inherit (inputs) haumea;
in haumea.lib.load {
  src = ./functions;
  transformer = haumea.lib.transformers.liftDefault;
  inputs = { inherit cell inputs; };
}
