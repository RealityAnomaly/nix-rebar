{
  description = "nix-rebar";

  inputs = {
    # intrinsic::channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    # intrinsic::libraries
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixago.url = "github:nix-community/nixago";
    std = {
      url = "github:divnix/std";
      inputs.nixago.follows = "nixago";
    };

    # platform::universal
    agenix.url = "github:ryantm/agenix";
    ragenix.url = "github:yaxitech/ragenix";
    sops-nix.url = "github:Mic92/sops-nix";

    # platform::linux
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, std, nixpkgs, ... }@inputs:
    std.growOn {
      inherit inputs;

      nixpkgsConfig = { allowUnfree = true; };

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      cellsFrom = ./cells;
      cellBlocks = with std.blockTypes; [
        # Library functions
        (data "data")
        (devshells "devshells")
        (installables "packages")
        (pkgs "overrides")
        (files "files")
        (functions "functions")
        (functions "overlays")

        # Modules
        (functions "commonModules")
        (functions "nixosModules")
        (functions "darwinModules")
        (functions "homeModules")

        # Profiles
        (functions "commonProfiles")
        (functions "nixosProfiles")
        (functions "darwinProfiles")
        (functions "homeProfiles")
        (functions "devshellProfiles")
      ];
    }
    {
      #packages = std.harvest inputs.self [ "common" "packages" ];
      functions = std.pick inputs.self [ "lib" "functions" ];

      commonModules = std.pick inputs.self [ "common" "commonModules" ];
      nixosModules = std.pick inputs.self [ "nixos" "nixosModules" ];
      #darwinModules = std.pick inputs.self [ "darwin" "darwinModules" ];
      #homeModules = std.pick inputs.self [ "home" "homeModules" ];

      commonProfiles = std.harvest inputs.self [ "common" "commonProfiles" ];
      nixosProfiles = std.harvest inputs.self [ "nixos" "nixosProfiles" ];
      darwinProfiles = std.harvest inputs.self [ "darwin" "darwinProfiles" ];
      #homeProfiles = std.harvest inputs.self [ "home" "homeProfiles" ];
      devshellProfiles = std.harvest inputs.self [ "common" "devshellProfiles" ];
    };
}
