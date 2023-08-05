{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }:
let cfg = config.rebar;
in {
  options.rebar = {
    inputs = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = lib.mdDoc ''
        The inputs of the parent flake. This must be a flake that conforms to the Rebar specification.
      '';
    };

    flake = lib.mkOption {
      # FIXME what is the type of a flake?
      type = lib.types.nullOr lib.types.raw;
      default = cfg.inputs.self;
      description = lib.mdDoc ''
        Flake that contains the nixos configuration.
      '';
    };

    symlinkFlake = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Symlinks the flake the system was built with to `/run/current-system`
        Having access to the flake the system was installed with can be useful for introspection.

        i.e. Get a development environment for the currently running kernel

        ```
        $ nix develop "$(realpath /run/booted-system/flake)#nixosConfigurations.turingmachine.config.boot.kernelPackages.kernel"
        $ tar -xvf $src
        $ cd linux-*
        $ zcat /proc/config.gz  > .config
        $ make scripts prepare modules_prepare
        $ make -C . M=drivers/block/null_blk
        ```

        Set this option to false if you want to avoid uploading your configuration to every machine (i.e. in large monorepos)
      '';
    };
  };
}
