{ root, inputs, cell, }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
in rec {
  homePath = pkgs: user:
    let inherit (pkgs.stdenv) hostPlatform;
    in if hostPlatform.isDarwin then
      "/Users/${user}"
    else if hostPlatform.isLinux then
      "/home/${user}"
    else
      "/home/${user}";

  systemTypes = let
    types = [
      { name = "core"; }
      { name = "workstation"; }
      {
        name = "graphical";
        predicate = system: system.isDarwin;
      }
    ];
  in root.utilities.genAttrs' types (value: {
    inherit value;
    inherit (value) name;
  });
}
