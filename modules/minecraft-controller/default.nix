{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.lgoette.services.minecraft-controller;
in
{

  options = {
    lgoette.services.minecraft-controller = {

      enable = mkEnableOption ''
        If enabled, start a Minecraft Server. The server
        data will be loaded from and saved to
        <option>services.minecraft-server.dataDir</option>.
      '';

      schedule = {

        enable = mkEnableOption ''
          If enabled, automatically shutdown the Minecraft server
          at night to save resources.
        '';

        start-time = mkOption {
          type = types.str;
          default = "10:00";
          description = ''
            Time of day in HH:MM (24h) when the Minecraft server should be
            automatically started. This will be converted to a cron expression
            as "MIN HOUR * * *". Example: "10:00" = daily at 10:00.
          '';
        };

        stop-time = mkOption {
          type = types.str;
          default = "02:00";
          description = ''
            Time of day in HH:MM (24h) when the Minecraft server should be
            automatically shutdown. This will be converted to a cron expression
            as "MIN HOUR * * *". Example: "02:00" = daily at 02:00.
          '';
        };

        stop-message = mkOption {
          type = types.str;
          default = "Server is shutting down in 10 minutes!";
          description = ''
            The message that will be sent to the Minecraft server
            10 minutes before automatic shutdown.
          '';
        };

      };

    };

  };

  config =
    let

      hasServers =
        (lib.hasAttr "minecraft-servers" config.services)
        && config.services.minecraft-servers.enable
        && config.services.minecraft-servers.servers != { };

      hasServer =
        (lib.hasAttr "minecraft-server" config.services) && config.services.minecraft-server.enable;

    in
    mkIf cfg.enable {

      lgoette.services.minecraft-controller.schedule.enable = lib.mkIf (!hasServer && !hasServers) (
        builtins.warn "No Servers configured. Turning off schedule." (lib.mkForce false)
      );

      services.cron =
        let
          # Get all enabled nix-minecraft (minecraft-servers) instances
          mcInstances =
            if hasServers then
              lib.attrNames (lib.filterAttrs (name: srv: srv.enable) config.services.minecraft-servers.servers)
            else
              [ ];

          # Time-calculation for shutdown message
          parseTime =
            timeStr:
            let
              parts = lib.splitString ":" timeStr;
            in
            {
              hour = lib.toIntBase10 (lib.elemAt parts 0);
              minute = lib.toIntBase10 (lib.elemAt parts 1);
            };

          stop = parseTime cfg.schedule.stop-time;
          start = parseTime cfg.schedule.start-time;

          # subtract 10 minutes for the warning message, wrap around midnight
          stopTotal = stop.hour * 60 + stop.minute;
          msgTotal = if stopTotal >= 10 then stopTotal - 10 else stopTotal - 10 + 24 * 60;
          msgHour = builtins.div msgTotal 60;
          msgMin = msgTotal - (msgHour * 60);

          toCron = t: "${toString t.minute} ${toString t.hour} * * *";

          # exported cron time strings
          msg-time-cron = "${toString msgMin} ${toString msgHour} * * *";
          start-time-cron = toCron start;
          stop-time-cron = toCron stop;

          # Generate cron jobs for all nix-minecraft (minecraft-servers) instances
          nixMinecraftJobs =
            if hasServers then
              lib.concatMap (
                inst:
                let
                  mcService = "minecraft-server-${inst}.service";
                  stopMessageCmd = "${pkgs.tmux}/bin/tmux -S ${config.services.minecraft-servers.runDir}/${inst}.sock send-keys -t 0 'say ${cfg.schedule.stop-message}' ENTER";
                in
                [
                  "${msg-time-cron}      root    ${stopMessageCmd}"
                  "${stop-time-cron}      root    ${pkgs.systemd}/bin/systemctl stop ${mcService}"
                  "${start-time-cron}      root    ${pkgs.systemd}/bin/systemctl start ${mcService}"
                ]
              ) mcInstances
            else
              [ ];

          # Generate cron jobs for single minecraft-server instance
          minecraftJobs =
            if hasServer then
              [
                "${msg-time-cron}      root    echo 'say ${cfg.schedule.stop-message}' > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}"
                "${stop-time-cron}      root    ${pkgs.systemd}/bin/systemctl stop minecraft-server.service"
                "${start-time-cron}      root    ${pkgs.systemd}/bin/systemctl start minecraft-server.service"
              ]
            else
              [ ];

        in
        {
          enable = lib.mkIf cfg.schedule.enable true;
          systemCronJobs = lib.concatLists [
            nixMinecraftJobs
            minecraftJobs
          ];
        };

    };
}
