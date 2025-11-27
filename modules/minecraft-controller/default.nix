{
  config,
  lib,
  nix-minecraft,
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

  config = mkIf cfg.enable {

    # Ferien Zeit 10-3
    # Normale Zeit: 10-2
    services.cron =
      let
        hasServers = lib.hasAttr "minecraft-servers" config.services;
        hasServer = lib.hasAttr "minecraft-server" config.services;

        # ensure exactly one of the two options is present
        _ensureOne =
          if hasServers != hasServer then
            true
          else
            builtins.throw "Please use services.minecraft-servers or services.minecraft-server (not both or none).";

        # If minecraft-servers
        mcInstances = if hasServers then lib.attrNames config.services.minecraft-servers.servers else [ ];
        mcInstance =
          if hasServers then
            (
              if mcInstances == [ ] then
                builtins.throw "services.minecraft-servers is set, but there is no instance."
              else
                builtins.elemAt mcInstances 0
            )
          else
            "";

        # Find Service-Name and Socket-Path:
        mcService =
          if hasServers then "minecraft-server-${mcInstance}.service" else "minecraft-server.service";
        cmd =
          if hasServers then
            "${pkgs.tmux}/bin/tmux -S ${config.services.minecraft-servers.runDir}/${mcInstance}.sock send-keys -t 0 'say ${cfg.schedule.stop-message}' ENTER"
          else
            "echo 'say ${cfg.schedule.stop-message}' > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}";

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

      in
      {
        enable = cfg.schedule.enable;
        systemCronJobs = [
          "${msg-time-cron}      root    ${cmd}"
          "${stop-time-cron}      root    ${pkgs.systemd}/bin/systemctl stop ${mcService}"
          "${start-time-cron}      root    ${pkgs.systemd}/bin/systemctl start ${mcService}"
        ];
      };
  };
}
