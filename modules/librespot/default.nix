{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lgoette.services.librespot;

in {
  options = {
    lgoette.services.librespot = {
      enable = mkEnableOption
        "If enabled, a librespot instance will be launched with the name <option>services.librespot.name</option>";

      name = mkOption {
        type = types.str;
        default = "Librespot";
        description = "Name shown in Spotify";
      };

      bitrate = mkOption {
        type = types.int;
        default = 320;
        description = "Bitrate for audio";
      };

      enableCache = mkOption {
        type = types.bool;
        default = false;
        description = "Enables caching for faster reponsetime";
      };

      initialVolume = mkOption {
        type = types.int;
        default = 75;
        description = "Initial volume in percent";
      };

      deviceType = mkOption {
        type = types.str;
        default = "speaker";
        description = ''
          Device Type (Icon shown in Spotify)
           Options are: computer, tablet, smartphone, speaker, tv, avr, stb, audiodongle, gameconsole, castaudio, castvideo, automobile, smartwatch, chromebook, carthing, homething'';
      };

      zeroconfigPort = mkOption {
        type = types.port;
        default = 54120;
        description = "Port for the zeroconfig response";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Opens the ports in the firewall for librespot";
      };
    };
  };

  config = mkIf cfg.enable {

    users.users.librespot = {
      description = "Librespot service user";
      createHome = false;
      isSystemUser = true;
      group = "librespot";
      extraGroups = [ "audio" "pulse-access" ];
      # shell = pkgs.zsh; # Shell for debugging
    };
    users.groups.librespot = { };

    systemd.services.librespot = {
      description = "Librespot Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        # ExecStart = ''
        #   ${pkgs.librespot} -n \"${cfg.name}\" -b ${cfg.bitrate}
        # '' + (if cfg.enableCache then ''
        #   -c ./cache 
        # '' else
        #   "") + ''
        #     --enable-volume-normalisation --initial-volume ${cfg.initialVolume} --device-type ${cfg.deviceType}" --zeroconf-port ${cfg.zeroconfigPort}
        #   '';

        # TODO: zeroconfigport not hardcoded. Somehow convert into string (in ExecStart)
        ExecStart = ''
          ${pkgs.librespot}/bin/librespot -n "${cfg.name}" -b 320 --enable-volume-normalisation --initial-volume 75 --device-type ${cfg.deviceType} --zeroconf-port 54120 --backend pulseaudio
        '';
        Restart = "on-failure";
        RestartSec = "5s";
        User = "librespot";
      };
    };

    # enable alsa
    # sound.enable = true; # sound is depricated

    # enable pulseaudio in system-wide mode (because our user has no home directory wich is mandatory for pulses default mode)
    hardware.pulseaudio = {
      enable = true;
      systemWide = true;
      daemon.logLevel = "info";
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts =
        [ cfg.zeroconfigPort ]; # 4070, 65535, 38143 für Librespot?
      allowedUDPPorts = [ 5353 ]; # mdns für Librespot
    };

  };
}
