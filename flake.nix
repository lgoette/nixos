{
  description = "A very basic flake";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    mayniklas.url = "github:mayniklas/nixos";
    mayniklas.inputs.nixpkgs.follows = "nixpkgs";
    mayniklas.inputs.home-manager.follows = "home-manager";
    mayniklas.inputs.flake-utils.follows = "flake-utils";

  };

  outputs = { self, ... }@inputs:
    with inputs;
    {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlays.default = final: prev: (import ./overlays inputs) final prev;

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs (map (x: {
        name = x;
        value = import (./modules + "/${x}");
      }) (builtins.attrNames (builtins.readDir ./modules)))

        //

        {

          home-manager = { pkgs, ... }: {
            imports =
              [ ./home-manager/home.nix ./home-manager/home-desktop.nix ];
          };

        };

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (map (x: {
        name = x;
        value = nixpkgs.lib.nixosSystem {

          # Make inputs and the flake itself accessible as module parameters.
          # Technically, adding the inputs is redundant as they can be also
          # accessed with flake-self.inputs.X, but adding them individually
          # allows to only pass what is needed to each module.
          specialArgs = { flake-self = self; } // inputs;

          system = "x86_64-linux";

          modules = [

            # https://github.com/MayNiklas/nixos/tree/main/modules
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

            (./machines + "/${x}/configuration.nix")
            { imports = builtins.attrValues self.nixosModules; }
            { nixpkgs.overlays = [ self.overlays.default ]; }

          ];
        };
      }) (builtins.attrNames (builtins.readDir ./machines)))

        //

        {
          pi4b-image = nixpkgs.lib.nixosSystem rec {
            specialArgs = { flake-self = self; } // inputs;
            system = "aarch64-linux";
            modules = [
              ./images/pi4b/configuration.nix
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              {
                imports = builtins.attrValues self.nixosModules
                  ++ builtins.attrValues mayniklas.nixosModules;
              }
              {
                nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                nix.registry.nixpkgs.flake = nixpkgs;
                sdImage.compressImage = false;
                sdImage.imageBaseName = "pi4b-image";

              }
            ];
          };
        };

    }

    //

    (flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ]) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
          };
        };
      in rec {
        # Custom packages added via the overlay are selectively exposed here, to
        # allow using them from other flakes that import this one.

        packages = flake-utils.lib.flattenTree {
          bukkit-spigot = pkgs.bukkit-spigot;
          minecraft-controller = pkgs.minecraft-controller;

          # Generate a sd-card image for the pi
          # nix build '.#pi4b-image'
          pi4b-image =
            self.nixosConfigurations.pi4b-image.config.system.build.sdImage;

        };

        apps = {
          # Allow custom packages to be run using `nix run`
          bukkit-spigot =
            flake-utils.lib.mkApp { drv = packages.bukkit-spigot; };
          minecraft-controller =
            flake-utils.lib.mkApp { drv = packages.minecraft-controller; };
        };
      });
}
