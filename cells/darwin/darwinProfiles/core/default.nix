{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }:
let inherit (inputs) cells;
in {
  imports = [
    # import the base profile for all platforms
    cells.common.commonProfiles.core.default

    # import cell modules
    cell.darwinModules.default

    # import the base profile for all platforms
    cells.common.commonProfiles.core.default

    # third-party modules we also always load
    inputs.ragenix.darwinModules.age
    #inputs.sops-nix.darwinModules.sops # no sops darwin module yet...

    # our own modules
    root.core.brew.default
    root.core.nix.default
    root.core.security.default
    root.core.shell.default
  ];

  environment.systemPackages = with pkgs; [ m-cli mas ];
  networking = { computerName = lib.mkDefault config.networking.hostName; };
}
