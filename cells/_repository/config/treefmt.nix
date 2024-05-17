{
  global.excludes = [ "*generated*" "*secrets.yaml" "*secrets.yml" ];
  formatter = {
    nix = {
      command = "sh";
      options = [
        "-euc"
        ''
          just statix check "$@"
          just deadnix check "$@"
          nixfmt "$@"
        ''
        "--"
      ];
      includes = [ "*.nix" ];
      excludes = [ ];
    };
    prettier = {
      command = "prettier";
      options = [ "--write" ];
      includes = [
        "*.css"
        "*.html"
        "*.json"
        "*.md"
        "*.mdx"
        "*.scss"
        "*.toml"
        "*.yaml"
        "*.yml"
      ];
      excludes = [ ];
    };
    shell = {
      command = "shfmt";
      # shfmt will read settings from `.editorconfig` as long as no parser or
      # printer flags are passed. See `man shfmt` for details.
      options = [ "--simplify" "--write" ];
      includes = [ "*.sh" "*.bash" ];
    };
  };
}
