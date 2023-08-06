{ root, inputs, cell, }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.cells.lib.functions.utilities) extractPair;
in rec {
  # Returns the manamgement interface for the specified machine
  primaryInterface = config:
    extractPair (_n: v: v.primary == true) config.networking.interfaces;

  # Returns the management IPv4 address for the specified machine
  primaryIPv4 = config:
    let iface = (primaryInterface config).value;
    in if (builtins.length iface.ipv4.addresses) > 0 then
      (lib.head iface.ipv4.addresses).address
    else
      null;

  # Returns the management IPv6 address for the specified machine
  primaryIPv6 = config:
    let iface = (primaryInterface config).value;
    in if (builtins.length iface.ipv6.addresses) > 0 then
      (lib.head iface.ipv6.addresses).address
    else
      null;
}
