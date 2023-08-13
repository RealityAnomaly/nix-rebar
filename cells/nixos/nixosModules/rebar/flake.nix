{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }:
let cfg = config.rebar;
in {
  config = lib.mkIf (cfg.flake != null) {
    system.extraSystemBuilderCmds = lib.optionalString cfg.symlinkFlake ''
      ln -s ${cfg.flake} $out/flake
    '';

    # check if the system is nixos
    services.telegraf.extraConfig.inputs.file = let
      inputsWithDate =
        lib.filterAttrs (_: input: input ? lastModified) cfg.inputs;
      flakeAttrs = input:
        (lib.mapAttrsToList (n: v: ''${n}="${v}"'')
          (lib.filterAttrs (_: v: (builtins.typeOf v) == "string") input));
      lastModified = name: input:
        ''
          flake_input_last_modified{input="${name}",${
            lib.concatStringsSep "," (flakeAttrs input)
          }} ${toString input.lastModified}'';

      # avoid adding store path references on flakes which me not need at runtime.
      promText = builtins.unsafeDiscardStringContext ''
        # HELP flake_registry_last_modified Last modification date of flake input in unixtime
        # TYPE flake_input_last_modified gauge
        ${lib.concatStringsSep "\n"
        (lib.mapAttrsToList lastModified inputsWithDate)}
      '';
    in [{
      data_format = "prometheus";
      files = [ (pkgs.writeText "flake-inputs.prom" promText) ];
    }];
  };
}
