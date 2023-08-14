{ inputs, cell, ... }:
let inherit (inputs) haumea;
in haumea.lib.load {
  src = ./overlays;
  inputs = { inherit cell inputs; };
}
