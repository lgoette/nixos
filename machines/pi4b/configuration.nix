{ self, ... }:
{ config, pkgs, lib, nixpkgs, nixos-hardware, ... }: {

  ### building the image
  # nix build .#nixosConfigurations.pi4b.config.system.build.sdImage

  # this workaround is currently needed to build the sd-image
  # basically: there currently is an issue that prevents the sd-image to be built successfully
  # remove this once the issue is fixed!
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  nix.registry.nixpkgs.flake = nixpkgs;
  sdImage.compressImage = false;
  sdImage.imageBaseName = "pi4b-image";
  ###

  imports = [
    ../../users/lasse.nix
    ../../users/root.nix

    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

  mayniklas = {
    locale.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    zsh.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    startWhenNeeded = true;
    kbdInteractiveAuthentication = false;
  };

  environment.systemPackages = with pkgs; [ bash-completion git nixfmt wget ];

  networking = {
    hostName = "pi4b";
    interfaces.eth0 = { useDHCP = true; };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "22.05";

}
