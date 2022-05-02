{ self, ... }:

{
  imports = [ ../../users/lasse.nix ../../users/root.nix ./wg0.nix ];

  mayniklas = {
    container.unifi = {
      enable = true;
      acmeMail = "acme@lasse-goette.de";
      domain = "unifi.lasse-goette.de";
      version = "7.1.61";
    };
    docker.enable = true;
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
    # interfaces.ens3 = {
    #   ipv6.addresses = [{
    #     address = "";
    #     prefixLength = 128;
    #   }];
    # };
    firewall = { enable = false; };
    nftables = {
      enable = true;
      rulesetFile = ./ruleset.nft;
    };
  };

  environment.systemPackages =
    with self.inputs.nixpkgs.legacyPackages.x86_64-linux; [
      bash-completion
      git
      nixfmt
      wget
    ];

  home-manager.users = {
    lasse = {
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
