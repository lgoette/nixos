{ self, ... }:

{
  imports = [ ../../users/lasse.nix ../../users/root.nix ];

  mayniklas = {
    user = {
      root.enable = true;
      nik.enable = true;
    };
    var.mainUser = "lasse";
    locale.enable = true;
    openssh.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    kvm-guest.enable = true;
    zsh.enable = true;
  };

  networking = {
    hostName = "wireguard";
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
    nik = {
      imports =
        [ ../../home-manager/nik.nix { nixpkgs.overlays = [ self.overlay ]; } ];
    };
  };

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 2);
  }];

}
