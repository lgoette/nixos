{
  description = "A very basic flake";

  # If not specifies, flake inputs default to the main / master branch.

  inputs = {

    # https://github.com/nixos/nixpkgs
    # Nix Packages collection & NixOS
    # This is the main input of the flake and specifies the NixOS version.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # https://github.com/NixOS/nixos-hardware
    # A collection of NixOS modules covering hardware quirks.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # https://github.com/nix-community/home-manager
    # Manage a user environment using Nix
    home-manager = {
      # Make sure the branch is correct for the version of nixpkgs you are using!
      # For example, if you are using nixpkgs-unstable, you should use the master branch.
      # For nixos-23.05, you should use the release-23.05 branch.
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/disko
    # Format disks with nix-config
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/plasma-manager
    # Manage Kde Plasma configuration using Nix
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/numtide/flake-utils
    # Pure Nix flake utility functions
    # Todo: completly get rid of those and use nixpkgs builtins
    flake-utils.url = "github:numtide/flake-utils";

    # https://github.com/nix-community/nixos-vscode-server
    # Visual Studio Code Server support in NixOS
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # https://github.com/musnix/musnix/
    # A collection of optimization options for realtime audio
    musnix.url = "github:musnix/musnix";

    # https://github.com/tale/headplane/
    # Headscale UI
    headplane = {
      # url = "github:tale/headplane/next";
      url = "github:tale/headplane";
    };

    # https://github.com/mayniklas/nixos
    # @MayNiklas NixOS configuration
    # We use a few modules from this flake as well as @MayNiklas home manager config
    mayniklas = {
      url = "github:mayniklas/nixos";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-utils.follows = "flake-utils";
        nixos-hardware.follows = "nixos-hardware";
        vscode-server.follows = "vscode-server";
        disko.follows = "disko";
      };
    };

    # https://github.com/pinpox/lollypops/
    # NixOS Deployment Tool
    # Old version (I change this when I have Time)
    lollypops = {
      url = "github:pinpox/lollypops/098b95c871a8fb6f246ead8d7072ec2201d7692b";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

  };

  outputs =
    { self, ... }@inputs:
    with inputs;
    let
      lib = nixpkgs.lib;

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );

      flakePkgs =
        pkgs:
        (builtins.listToAttrs (
          map (name: {
            inherit name;
            value = pkgs.callPackage (./pkgs + "/${name}") { flake-self = self; };
          }) (builtins.attrNames (builtins.readDir ./pkgs))
        ));
    in
    {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlays.default = import ./overlays inputs;

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules =
        builtins.listToAttrs (
          map (x: {
            name = x;
            value = import (./modules + "/${x}");
          }) (builtins.attrNames (builtins.readDir ./modules))
        )
        // {

          # lgoette.mayniklas
          # -> imports used flake inputs
          # -> this way, they can easily be imported to different flake outputs
          mayniklas =
            { ... }:
            {
              imports = [
                # https://github.com/MayNiklas/nixos/tree/main/modules
                mayniklas.nixosModules.cloud-provider-default
                mayniklas.nixosModules.cloud-provider
                mayniklas.nixosModules.docker
                mayniklas.nixosModules.home-manager
                mayniklas.nixosModules.iperf
                mayniklas.nixosModules.locale
                mayniklas.nixosModules.minecraft
                mayniklas.nixosModules.monitoring
                mayniklas.nixosModules.nix-common
                mayniklas.nixosModules.openssh
                mayniklas.nixosModules.options
                mayniklas.nixosModules.sound
                mayniklas.nixosModules.user
                mayniklas.nixosModules.zsh
              ];
            };

        };

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (
        map (x: {
          name = x;
          value = nixpkgs.lib.nixosSystem {

            # Make inputs and the flake itself accessible as module parameters.
            # Technically, adding the inputs is redundant as they can be also
            # accessed with flake-self.inputs.X, but adding them individually
            # allows to only pass what is needed to each module.
            specialArgs = {
              flake-self = self;
            }
            // inputs;

            modules =
              builtins.attrValues self.nixosModules
              ++ [ lollypops.nixosModules.lollypops ]
              ++ [
                {
                  nixpkgs.overlays = [
                    self.overlays.default
                    headplane.overlays.default
                  ];
                }
                (import "${./.}/machines/${x}/configuration.nix")
              ];

          };
        }) (builtins.attrNames (builtins.readDir ./machines))
      );

      homeConfigurations = forAllSystems (
        system:
        (lib.concatMapAttrs (
          profileName: profile:
          let
            configForUser =
              username:
              home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgsFor.${system};
                modules = [
                  profile
                  {
                    home.username = lib.mkDefault username;
                    home.homeDirectory = lib.mkDefault (if username == "root" then "/root" else "/home/${username}");
                  }
                ];
                extraSpecialArgs = {
                  flake-self = self;
                  system-config = builtins.warn ''
                    system-config is being accessed from standalone home-manager.
                    This will fall back to an empty attribute set.
                  '' { };
                }
                // inputs;
              };
          in
          {
            # defition of usernames
            "${profileName}" = configForUser "lasse";
            "${profileName}-root" = configForUser "root";
          }
        ) self.homeProfiles)
      );

      homeProfiles = builtins.listToAttrs (
        map (filename: {
          name = builtins.substring 0 ((builtins.stringLength filename) - 4) filename;
          value = {
            imports = [
              ./home-manager/profiles/common.nix
              (./home-manager/profiles + "/${filename}")
            ]
            ++ (builtins.attrValues self.homeModules);
          };
        }) (builtins.attrNames (builtins.readDir ./home-manager/profiles))
      );

      homeModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import (./home-manager/modules + "/${name}");
        }) (builtins.attrNames (builtins.readDir ./home-manager/modules))
      );
    }

    //

      (flake-utils.lib.eachSystem supportedSystems) (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ ];
            config = {
              allowUnsupportedSystem = true;
              allowUnfree = true;
            };
          };
        in
        {

          formatter = pkgs.nixfmt-tree;

          # Custom packages added via the overlay are selectively exposed here, to
          # allow using them from other flakes that import this one.

          packages = flake-utils.lib.flattenTree {
            build_outputs = pkgs.callPackage mayniklas.packages.${system}.build_outputs.override {
              inherit self;
              output_path = "~/.keep-nix-outputs-lgoette";
            };

            woodpecker-pipeline = pkgs.callPackage ./packages/woodpecker-pipeline {
              inputs = inputs;
              flake-self = self;
            };
          };

          apps = {
            lollypops = lollypops.apps.${pkgs.system}.default { configFlake = self; };
          };
        }
      );
}
