{ self, ... }:

{
  imports = [ ../../users/lasse.nix ../../users/root.nix ./wg0.nix ];

  lgoette = {
    nginx = {
      enable = true;
      workshop = true;
      urban-disclaimer = true;
    };
  };

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

  # systemd.services.docker.reloadTriggers = [ "nftables.service" ];
  # systemd.services.docker.restartTriggers = [ "nftables.service" ];

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
    # interfaces.ens3 = {
    #   ipv6.addresses = [{
    #     address = "";
    #     prefixLength = 128;
    #   }];
    # };
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
