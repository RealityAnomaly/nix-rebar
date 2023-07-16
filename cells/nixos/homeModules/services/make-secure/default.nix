{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.make-secure;
in {
  options.services.make-secure = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.make-secure = {
      Install = { WantedBy = [ "graphical-session.target" ]; };

      Unit = {
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = let
        script = with pkgs;
          substituteAll {
            src = ./secure.sh;
            isExecutable = true;
            inherit bash dbus;
            inherit (stdenv) shell;
          };
      in {
        ExecStart = toString script;
        Restart = "always";
      };
    };
  };
}
