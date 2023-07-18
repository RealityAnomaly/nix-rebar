_inputs@{ cell, inputs, }:
let
  pkgs = inputs.nixpkgs;
  inherit (inputs) cells;
  inherit (pkgs) lib system;

  buildSystems = lib.mapAttrs (name: value:
    { config, ... }: {
      imports = [
        cells.common.commonProfiles.core.default
        cell.nixosProfiles.core.default
      ] ++ value.modules;

      rebar = {
        inherit inputs;

        enable = true;
        host = { inherit system; };
      };

      networking.hostName = name;
      system.stateVersion = config.system.nixos.version;
      users.users.root.initialPassword = "fnord23";
      boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
      fileSystems."/".device = lib.mkDefault "/dev/sda";
    });
in buildSystems {
  # example-common = {
  #   modules = [];
  # };

  # example-server = {
  #   modules = [
  #     cell.nixosProfiles.classes.server.default
  #   ];
  # };
}
