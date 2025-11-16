{ config, lib, nix-minecraft, pkgs, ... }:

with lib;

let cfg = config.lgoette.services.minecraft-server;
in {
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
              url = "https://cdn.modrinth.com/data/swbUV1cr/versions/KDFOHrSO/bluemap-5.13-paper.jar";
              sha512 = "858805ca7187216b82817fb3e697a9d5bfb8d215f399dee653f9152bea4b6292d1d271c6287195cafa53cdec774e964e8a6d6a7ed018e397e72525d102c4dc0c";
            };
          };
        };
      };
    };
  };

}
