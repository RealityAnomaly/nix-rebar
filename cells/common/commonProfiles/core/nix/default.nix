{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
let inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [ root.core.nix.substituters.default ];

  nix = {
    package = pkgs.nix;

    settings = {
      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      # Enable content addressing, flakes, and nix-command
      experimental-features = [ "ca-derivations" "flakes" "nix-command" ];

      # Builds have recently become unusably interrupted on Darwin
      # <https://github.com/NixOS/nix/issues/7273>
      auto-optimise-store = !isDarwin;
      sandbox = lib.mkDefault (!isDarwin);

      # Allow trusted users
      allowed-users = [ "*" ];
      trusted-users = [ "root" "@wheel" ];

      # The default at 10 is rarely enough.
      log-lines = lib.mkDefault 25;

      # Avoid disk full issues
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);

      # TODO: cargo culted.
      daemonCPUSchedPolicy = lib.mkIf (!isDarwin) (lib.mkDefault "batch");
      daemonIOSchedClass = lib.mkIf (!isDarwin) (lib.mkDefault "idle");
      daemonIOSchedPriority = lib.mkIf (!isDarwin) (lib.mkDefault 7);
    };

    gc.automatic = true;

    extraOptions = ''
      warn-dirty = false
    '';
  };
}
