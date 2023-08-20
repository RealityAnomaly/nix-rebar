/* *
   Preprocessor for Nix configurations to automatically extract suites based on the system type.

   Example:
     mkConfiguration inputs {
       system = "aarch64-darwin";
       types = [ systemTypes.workstation ];
       platformStateVersion = 4;
     } {
       networking.computerName = "A MacBook Pro";
     };
     => { imports = [ ... ]; rebar = { ... }; system = { ... }; }
*/
{ root, inputs, cell, }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (root.modules) extractSuites;
in inputs:
{ system, types ? [ ], commonModules ? [ ], platformModules ? [ ]
, platformStateVersion, homeModules ? [ ], }:
defaultModule:
let
  cells = inputs.cells or { };

  # parse the system string provided and extract its type
  parsedSystem = lib.systems.elaborate system;
  extractSuites' = extractSuites { inherit system types; };

  commonSuites = extractSuites' [ ] (cells.common.commonSuites or { });
  platformSuites = let
    platform = if parsedSystem.isDarwin then
      cells.darwin.darwinSuites or { }
    else if parsedSystem.isLinux then
      cells.nixos.nixosSuites or { }
    else
      throw "Unsupported system type";
  in extractSuites' [ ] platform;
  homeSuites = extractSuites' [ ] (cells.home.homeSuites or { });
in {
  imports = commonModules ++ commonSuites ++ platformModules ++ platformSuites
    ++ [ defaultModule ];

  rebar = {
    inherit inputs;

    enable = true;
    host = { inherit system types; };
  };

  home-manager.sharedModules = homeModules ++ homeSuites;
  system = { stateVersion = platformStateVersion; };
}
