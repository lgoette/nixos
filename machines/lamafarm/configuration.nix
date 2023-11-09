{ self, ... }:
{ pkgs, lib, mayniklas, flake-self, ... }:

{
  imports = [
    ../../users/lasse.nix
    ../../users/root.nix
    ./wg0.nix
    # home-manager.nixosModules.home-manager
  ];

  lgoette = {
    nginx = {
      enable = true;
      workshop = true;
      urban-disclaimer = true;
    };

    unifi-controller = {
      enable = true;
      domain = "unifi.lasse-goette.de";
    };

    # user.lasse.home-manager.enable = true; # Old home-manager configuration variant

  };

  mayniklas = {
    user = { root.enable = true; };
    var.mainUser = "lasse";
    locale.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    cloud.netcup-x86.enable = true;
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

    users.lasse = flake-self.homeConfigurations.server;
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
    hostName = "lamafarm";
    firewall = {
      enable = false;
      allowedTCPPorts = [ 50937 ];
    };
    nftables = {
      enable = true;
      rulesetFile = ./ruleset.nft;
    };
    interfaces.ens3 = {
      ipv6.addresses = [{
        address = "2a03:4000:6:2587::";
        prefixLength = 64;
      }];
    };
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
      wg-friendly-peer-names
    ];

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 2);
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "22.05";

}
