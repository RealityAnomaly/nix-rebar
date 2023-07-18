{
  description = "nix-rebar";

  inputs = {
    # intrinsic::channels
    nixpkgs.follows = "nixos-stable";
    nixpkgs-stable.follows = "nixos-stable";
    nixpkgs-unstable.follows = "nixos-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # intrinsic::libraries
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hive = {
      url = "github:divnix/hive";
      inputs = {
        colmena.follows = "colmena";
        disko.follows = "disko";
        haumea.follows = "haumea";
        home.follows = "home";
        home-manager.url = "github:divnix/blank";
        nixos-generators.follows = "nixos-generators";
        nixpkgs.follows = "nixpkgs";
        paisano.follows = "paisano";
      };
    };
    home = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    makes = {
      url = "github:fluidattacks/makes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    namaka = {
      url = "github:nix-community/namaka/v0.2.0";
      inputs = {
        haumea.follows = "haumea";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixago.url = "github:nix-community/nixago";
    n2c = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paisano = {
      url = "github:divnix/paisano";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:divnix/std";
      inputs = {
        arion.follows = "arion";
        devshell.follows = "devshell";
        makes.follows = "makes";
        microvm.follows = "microvm";
        nixago.follows = "nixago";
        n2c.follows = "n2c";
        terranix.follows = "terranix";
      };
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # intrinsic::packages
    colmena.url = "github:zhaofengli/colmena";
    deploy-rs.url = "github:serokell/deploy-rs";

    # platform::universal
    agenix.url = "github:ryantm/agenix";
    ragenix.url = "github:yaxitech/ragenix";
    sops-nix.url = "github:Mic92/sops-nix";

    # platform::linux
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, std, nixpkgs, hive, ... }@inputs:
    hive.growOn {
      inherit inputs;

      nixpkgsConfig = { allowUnfree = true; };

      systems =
        [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

      cellsFrom = ./cells;
      cellBlocks = with std.blockTypes;
        with hive.blockTypes; [
          # Library functions
          (functions "checks")
          #(data "data")
          (devshells "devshells" { ci.build = true; })
          #(installables "packages")
          (namaka "snapshots" { ci.check = true; })
          (nixago "config")
          #(pkgs "overrides")
          #(files "files")
          (functions "functions")
          #(functions "overlays")

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

          # Configurations
          nixosConfigurations
          diskoConfigurations
        ];
    } {
      # collect :: collects everything, no cell block ref is necessary
      # harvest :: system.cell.block.target -> system.target
      # pick :: system.cell.block.target -> target (no system is necessary)
      # winnow :: system.cell.block.target -> system.target (filtered version of harvest)

      #packages = std.harvest inputs.self [ "common" "packages" ];
      checks = std.harvest self [
        [ "_repository" "snapshots" "default" "check" ] # namaka snapshot tests
        [ "nixos" "checks" ]
      ];
      devShells = hive.harvest self [ "_repository" "devshells" ];
      functions = std.pick self [ "lib" "functions" ];

      commonModules = std.pick self [ "common" "commonModules" ];
      nixosModules = std.pick self [ "nixos" "nixosModules" ];
      darwinModules = std.pick self [ "darwin" "darwinModules" ];
      #homeModules = std.pick self [ "home" "homeModules" ];

      commonProfiles = std.harvest self [ "common" "commonProfiles" ];
      nixosProfiles = std.harvest self [ "nixos" "nixosProfiles" ];
      darwinProfiles = std.harvest self [ "darwin" "darwinProfiles" ];
      #homeProfiles = std.harvest self [ "home" "homeProfiles" ];
      devshellProfiles = std.harvest self [ "common" "devshellProfiles" ];

      nixosConfigurations = hive.collect self "nixosConfigurations";
      diskoConfigurations = hive.collect self "diskoConfigurations";
    };
}
