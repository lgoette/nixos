{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lgoette.services.minecraft-backup;
in {
  options = {
    lgoette.services.minecraft-backup = {
      enable = mkEnableOption
        "If enabled, the Minecraft Server will be stopped, backed up into a Zip file and startet again in an interval. The file is located at <option>services.minecraft-backup.dataDir</option> and will be published with a running webservice";
      dataDir = mkOption {
        type = types.path;
        default = "/var/www/minecraft-backup";
        description = "Path where the Zip file is stored";
      };
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Opens the ports in the firewall for the webservice";
      };
      enableWebservice = mkOption {
        type = types.bool;
        default = false;
        description = "Opens the ports in the firewall for the webservice";
      };
    };
  };

  config = mkIf (cfg.enable && (config.services.minecraft-server.enable || config.services.minecraft-servers.enable)) {

    systemd.services.minecraft-backup = let
      serverDataDir = if config.services.minecraft-server.enable
              then config.services.minecraft-server.dataDir
              else if config.services.minecraft-servers.enable
              then config.services.minecraft-servers.dataDir
              else throw "Minecraft backup enabled but no Minecraft server found!";
    in {
      serviceConfig = {
      User = "root";
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.minecraft-backup}/bin/minecraft-backup ${cfg.dataDir} ${serverDataDir}
      '';
      };
    };

    systemd.timers.minecraft-backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "minecraft-backup.service" ];
      timerConfig.OnCalendar = "*-*-* 05:00:00";
    };

    services.nginx = mkIf cfg.enableWebservice {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      virtualHosts."backup.minecraft" = {
        default = true;
        root = "${cfg.dataDir}";
        listen = [{
          addr = "10.11.12.8";
          port = 80;
          ssl = false;
        }];
      };
    };

    networking.firewall.interfaces.wg0.allowedTCPPorts =
      mkIf (cfg.openFirewall && cfg.enableWebservice) [ 80 ];

  };
}
