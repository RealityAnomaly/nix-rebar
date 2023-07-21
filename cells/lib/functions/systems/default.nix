{ root, inputs, cell, }: rec {
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
      { name = "server"; }
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
