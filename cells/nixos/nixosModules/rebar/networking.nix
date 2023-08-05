{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  # enlighten the interface configuration with an extra primary option,
  # which specifies this interface should be where management traffic is routed
  options.networking.interfaces = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule {
        options.primary = lib.mkOption {
          type = types.bool;
          default = false;
          description =
            "Whether this interface should be used for management traffic.";
        };
      });
  };

  config = {
    assertions = [{
      assertion = lib.all (iface: iface.primary)
        (lib.attrValues config.networking.interfaces);
      message =
        "There must be exactly one management network interface set with 'networking.interfaces.<name>.primary'.";
    }];
  };
}
