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
      allowedIPs = [ "10.11.12.1/32" ];
    };
  };

  mayniklas = {
    services = {
      minecraft-server = {
        enable = true;
        dataDir = "/var/lib/minecraft";
        declarative = true;
        eula = true;
        jvmOpts = "-Xmx3584m -Xms2048m";
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
        };
        ops = {
          BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
          JulianRooms = "a89ab984-6b22-4ba1-902a-8e44f65c6df7";
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

}
