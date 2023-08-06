{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  environment = {
    variables = rec {
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

    # shells = with pkgs; [
    #   bashInteractive
    #   # fish
    #   zsh
    # ];

    # Install completions for system packages.
    pathsToLink = [ "/share/bash-completion" ]
      ++ (lib.optional config.programs.fish.enable "/share/fish")
      ++ (lib.optional config.programs.zsh.enable "/share/zsh");
  };
}
