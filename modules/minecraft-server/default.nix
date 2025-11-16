{ config, lib, nix-minecraft, pkgs, ... }:

with lib;

let cfg = config.lgoette.services.minecraft-server;
in {
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  options = {
    lgoette.services.minecraft-server = {

      enable = mkEnableOption
        ''
          If enabled, start a Minecraft Server. The server
          data will be loaded from and saved to
          <option>services.minecraft-server.dataDir</option>.
        '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      dataDir = "/var/lib/minecraft-servers";

      servers = {
        vanilla = {
          enable = true;
          package = pkgs.paperServers.paper-1_21_10;
          openFirewall = true;
          autoStart = true;
          jvmOpts = "-Xms2G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";

          symlinks = {
            "plugins/bluemap-5.13-paper.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/swbUV1cr/versions/wpE4tHiK/bluemap-5.13-paper.jar";
              hash = "sha256-KkMLP09ZZN+Ev4WhRp4BA6l+applaGAJbwurzwTsUqc=";
            };
          };
        };
      };
    };
  };

}
