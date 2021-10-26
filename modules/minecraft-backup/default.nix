{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lgoette.services.minecraft-backup;
in {
  options = {
    lgoette.services.minecraft-backup = {
      enable = mkEnableOption "If enabled, the Minecraft Server will be stopped, backed up into a Zip file and startet again in an interval. The file is located at <option>services.minecraft-backup.dataDir</option> and will be published with a running webservice";
      dataDir = mkOption {
        type = types.path;
        default = "/home/lasse";
        description = "Path where the Zip file is stored";
      };
      openFirewall = mkOption {
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
          systemctl start minecraft-server
        ''; # TODO: Get service.minecraft-server cfg.dataDir
        #minutely 
      };
    };
    systemd.timers.minecraft-backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "minecraft-backup.service" ];
      timerConfig.OnCalendar = "*-*-* *:05:00";
    };
    #TODO: Hier Zip über webserver bereitstellen mit port über webservicePorts definiert
  };
}
