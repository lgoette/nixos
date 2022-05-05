{ self, ... }:

{
  imports = [ ../../users/lasse.nix ../../users/root.nix ./wg0.nix ];

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

  };

  mayniklas = {
    user = { root.enable = true; };
    var.mainUser = "lasse";
    locale.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    kvm-guest.enable = true;
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

  environment.systemPackages =
    with self.inputs.nixpkgs.legacyPackages.x86_64-linux; [
      bash-completion
      git
      nixfmt
      wget
      wg-friendly-peer-names
    ];

  home-manager.users = {
    lasse = {
      # packages from mayniklas
      home.packages = with self.inputs.mayniklas.packages.x86_64-linux; [
        drone-gen
        vs-fix
      ];
      imports = [
        ../../home-manager/lasse.nix
        { nixpkgs.overlays = [ self.overlay ]; }
      ];
    };
  };

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 2);
  }];

}
