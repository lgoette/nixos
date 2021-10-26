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

  config = mkIf cfg.enable {

    systemd.services.minecraft-backup = {
      serviceConfig = {
        User = "root";
        Type = "oneshot";
        ExecStart = ''
          systemctl stop minecraft-server ; \
           ${pkgs.zip}/bin/zip -r ${cfg.dataDir}/minecraft.zip /var/lib/minecraft ; \
          systemctl start minecraft-server ; \
          ${pkgs.coreutils}/bin/chown nginx:nginx /var/www/minecraft-backup/minecraft.zip ; \
          ${pkgs.coreutils}/bin/chmod 550 /var/www/minecraft-backup/minecraft.zip
        '';
      };
    };

    systemd.timers.minecraft-backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "minecraft-backup.service" ];
      timerConfig.OnCalendar = "*-*-* *:05:00";
    };

    services.nginx = {
      enable = true;
      virtualHosts."backup.minecraft" = {
        default = true;
        root = "/var/www/minecraft-backup";
        listen = [{
          addr = "10.11.12.8";
          port = 80;
          ssl = false;
        }];
      };
    };

    networking.firewall.interfaces.wg0.allowedTCPPorts = [ 80 ];

  };
}
