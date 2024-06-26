{ self, ... }:
{ pkgs, config, lib, mayniklas, flake-self, ... }:

{
  imports = [
    ../../users/lasse.nix
    ../../users/root.nix
  ];

  lgoette = {
    
  };

  mayniklas = {
    user = { root.enable = true; };
    var.mainUser = "lasse";
    locale.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    zsh.enable = true;
  };

  # Home Manager configuration
  home-manager = {
    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    useUserPackages = true;

    extraSpecialArgs = {
      # Pass all flake inputs to home-manager modules aswell so we can use them
      # there.
      inherit flake-self;
      # Pass system configuration (top-level "config") to home-manager modules,
      # so we can access it's values for conditional statements
      system-config = config;
    };

    users.lasse = flake-self.homeConfigurations.common;
  };

  # Prepare system for realtime audio
  musnix = {
    enable = true;
    kernel.realtime = true;
    ffado.enable = false; # Firewire drivers
    rtcqs.enable = true; # Commandline tool for checking configuration
  };
  users.extraUsers.lasse.extraGroups = [ "audio" ];

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
    hostName = "lamabus";
    firewall = {
      enable = false;
      allowedTCPPorts = [ 50937 ];
    };
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
    ];

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 2);
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "22.05";

}