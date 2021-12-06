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
    services.minecraft-backup = {
      enable = true;
      enableWebservice = true; 
      openFirewall = true;
    };
  };

  mayniklas = {
    minecraft-server = {
      enable = true;
      dataDir = "/var/lib/minecraft";
      declarative = true;
      eula = true;
      jvmOpts = "-Xms2048m -Xmx3584m";
      openFirewall = true;
      serverProperties = {
        difficulty = 2;
        gamemode = 0;
        max-players = 10;
        motd =
          "\\u00a7e\\u273f\\u00a72\\u00a7lLamacraft\\u00a7e\\u273f\\nMap: Brave New World";
        white-list = true;
      };
      whitelist = {
        BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
        mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
        hellslime2000 = "41555a0b-9a6f-4596-98eb-d60ed5b02cb3";
        Endslime2000 = "8e82ce9f-80fe-4a23-ab3e-464e0d3776f6";
        EnderSnow_ = "73341ad1-dabb-4547-b00e-33fb1c488464";
        hako55 = "df1fc00d-e816-4356-870c-a1492be67740";
        PlanetMaker3000 = "e909c435-b18f-4bea-94c8-ead3b843f2c6";
      };
      ops = {
        BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
        mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
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
