{ self, ... }:

{
  imports = [
    # Users
    ../../users/lasse.nix
    ../../users/nik.nix
    ../../users/root.nix

    ### to build disk image:
    ### nix build .#nixosConfigurations.minecraft.config.system.build.vmwareImage

    # ./disk-image.nix
  ];

  lgoette = {
    wg = {
      enable = true;
      ip = "10.11.12.8";
      allowedIPs = [ "10.11.12.0/24" "0.0.0.0/0" ];
    };
  };

  mayniklas = {
    services = {
      minecraft-server = {
        enable = true;
        dataDir = "/var/lib/minecraft";
        declarative = true;
        eula = true;
        jvmOpts = "-Xms2048m -Xmx3584m";
        openFirewall = true;
        serverProperties = {
          difficulty = 3;
          gamemode = 1;
          max-players = 10;
          motd = "NixOS Minecraft server!";
          white-list = true;
        };
        whitelist = {
          BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
          JulianRooms = "a89ab984-6b22-4ba1-902a-8e44f65c6df7";
          mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
        };
        ops = {
          BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
          JulianRooms = "a89ab984-6b22-4ba1-902a-8e44f65c6df7";
          mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
        };
      };
    };
    var.mainUser = "lasse";
    locale.enable = true;
    openssh.enable = true;
    nix-common = {
      enable = true;
      disable-cache = true;
    };
    vmware-guest.enable = true;
    zsh.enable = true;
  };

  networking = { hostName = "minecraft"; };

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
        { nixpkgs.overlays = [ self.overlay self.overlay-unstable ]; }
      ];
    };
    nik = {
      imports = [
        ../../home-manager/nik.nix
        { nixpkgs.overlays = [ self.overlay self.overlay-unstable ]; }
      ];
    };
  };

}
