{ self, ... }:
{ config, pkgs, lib, nixpkgs, nixos-hardware, mayniklas, home-manager, ... }: {

  ### building the image
  # nix build .#nixosConfigurations.lamaoutpost.config.system.build.sdImage

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
    self.pi.pi4b
    ../../users/lasse.nix
    ../../users/root.nix
    ./wg0.nix

    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    nixos-hardware.nixosModules.raspberry-pi-4
  ];


  lgoette = {
    user.lasse.home-manager.enable = true;
  };

  mayniklas = {
    var.mainUser = "lasse";
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
    listenAddresses = [{
      addr = "0.0.0.0";
      port = 50937;
    }];
  };

  networking = {
    hostName = "lamaoutpost";
    usePredictableInterfaceNames = false;
    firewall.allowedTCPPorts = [ 50937 ];
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
    ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "22.05";

}
