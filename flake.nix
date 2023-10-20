# SPDX-FileCopyrightText: 2023 Alex XZ Cypher Zero <legal@alex0.net>
#
# SPDX-License-Identifier: ARR

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
    flake-parts.url = "github:hercules-ci/flake-parts";
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
        home-manager.follows = "home";
        nixos-generators.follows = "nixos-generators";
        nixpkgs.follows = "nixpkgs";
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
    nixt.url = "github:nix-community/nixt";
    n2c = {
      url = "github:nlewo/nix2container";
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
    yants.url = "github:divnix/yants";

    # thirdparty
    tvl = {
      url = "git+https://cl.tvl.fyi/depot.git";
      flake = false;
    };

    # intrinsic::packages
    colmena.url = "github:zhaofengli/colmena/v0.4.0";
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

  outputs = { self, std, nixpkgs, hive, ... }@inputs: hive.growOn {
      inherit inputs;

      nixpkgsConfig = { allowUnfree = true; };

      systems =
        [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

      cellsFrom = ./cells;
      cellBlocks = with std.blockTypes;
        with hive.blockTypes; [
          # Library functions
          (functions "checks")
          (data "data")
          (anything "tests")
          (devshells "devshells" { ci.build = true; })
          #(installables "packages")
          (namaka "snapshots" { ci.check = true; })
          (nixago "config")
          #(pkgs "overrides")
          #(files "files")
          (functions "overlays")

          # functions that use our import signature
          (functions "functions") 
          # external functions using a shim
          (functions "vendor")

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
    } (let
      tests = hive.pick self [ "lib" "tests" ];
    in rec {
      # collect :: collects everything, no cell block ref is necessary
      # harvest :: system.cell.block.target -> system.target
      # pick :: system.cell.block.target -> target (no system is necessary)
      # winnow :: system.cell.block.target -> system.target (filtered version of harvest)

      #packages = std.harvest inputs.self [ "common" "packages" ];
      checks = hive.harvest self [
        [ "_repository" "snapshots" "default" "check" ] # namaka snapshot tests
        [ "nixos" "checks" ]
      ];

      data = hive.pick self [ "lib" "data" ];
      devShells = hive.harvest self [ "_repository" "devshells" ];
      functions = hive.pick self [ "lib" "functions" ];
      overlays = hive.collect self "overlays";

      vendor = hive.pick self [ "lib" "vendor" ];

      commonModules = hive.pick self [ "common" "commonModules" ];
      nixosModules = hive.pick self [ "nixos" "nixosModules" ];
      darwinModules = hive.pick self [ "darwin" "darwinModules" ];
      #homeModules = hive.pick self [ "home" "homeModules" ];

      commonProfiles = hive.harvest self [ "common" "commonProfiles" ];
      nixosProfiles = hive.harvest self [ "nixos" "nixosProfiles" ];
      darwinProfiles = hive.harvest self [ "darwin" "darwinProfiles" ];
      #homeProfiles = hive.harvest self [ "home" "homeProfiles" ];
      devshellProfiles = hive.harvest self [ "common" "devshellProfiles" ];

      nixosConfigurations = hive.collect self "nixosConfigurations";
      diskoConfigurations = hive.collect self "diskoConfigurations";

      __nixt = functions.tests.loadNixt tests;
      __nixTests = functions.tests.loadNixpkgs tests;
    });
}
