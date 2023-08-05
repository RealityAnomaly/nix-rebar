{ root, inputs, cell, ... }: # scope::cell
{ self, config, lib, pkgs, ... }: # scope::eval-config
let l = lib // builtins;
in {
  imports = [
    # import the common modules
    cell.commonModules.default

    # default profiles for this profile
    root.core.nix.default
    root.core.secrets.default
    root.core.security.default
  ];

  environment.variables = rec {
    EDITOR = "vim";
    PAGER = "less -R";
    LESS = "-R"; # -iFJMRW -x4
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    SYSTEMD_LESS = LESS;

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Although it points to a commonly-used path for user-owned executables,
    # $XDG_BIN_HOME is a non-standard environment variable. It is not part of
    # the XDG Base Directory Specification.
    # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  # environment.shells = with pkgs; [
  #   bashInteractive
  #   # fish
  #   zsh
  # ];

  # Install completions for system packages.
  environment.pathsToLink = [ "/share/bash-completion" ]
    ++ (l.optional config.programs.fish.enable "/share/fish")
    ++ (l.optional config.programs.zsh.enable "/share/zsh");

  programs.zsh = {
    enable = l.mkDefault true;
    shellInit = l.mkDefault "";
    loginShellInit = l.mkDefault "";
    interactiveShellInit = l.mkDefault "";

    # Prompts/completions/widgets should never be initialised at the
    # system-level because it will need to be initialised a second time once the
    # user's zsh configs load.
    promptInit = l.mkForce "";
    enableCompletion = l.mkForce false;
    enableBashCompletion = l.mkForce false;
  };

  # programs.fish.enable = l.mkDefault true;
}
