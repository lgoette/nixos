{ config, pkgs, lib, ... }:
with lib;
let
  cfg =
    config.lgoette.home-assistant;

in {
  options.lgoette.home-assistant =
    {
      enable = mkEnableOption "Home-assitant server";

      timezone = mkOption {
        type = types.str;
        default = "Europe/Berlin";
        description = ''
          Timzone, home assistant is using.
        '';
      };

      path = mkOption {
        type = types.str;
        default = "/docker/home-assistant";
        description = ''
          Path for the home assistant config
        '';
      };

    };

  config = mkIf cfg.enable {

    # enable home assistant docker container
    virtualisation.oci-containers.containers.home-assistant = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant:stable";
      environment = { TZ = "${cfg.timezone}"; };
      ports = [ "8123:8123" ];
      volumes =
        [ "${cfg.path}/config:/config:rw" "/etc/localtime:/etc/localtime:ro" ];
      extraOptions =
        [ "--privileged" "--network=host" ]; # "--restart=unless-stopped"
    };

    # Open port for mqtt
    networking.firewall = {

      allowedTCPPorts = [ 1883 ];

      # Expose home-assitant to the wireguard network
      interfaces.wg0.allowedTCPPorts = [ 8123 ];
    };

    # Enable mosquitto MQTT broker
    services.mosquitto = {
      enable = true;

      # Mosquitto is only listening on the local IP, traffic from outside is not
      # allowed.
      listeners = [{
        # address = "192.168.176.4"; needed?
        port = 1883;
        users = {
          # No real authentication needed here, since the local network is
          # trusted.
          mosquitto = {
            acl = [ "readwrite #" ];
            password = "mosquitto"; # move to secrets
          };
          home = {
            acl = [
              "readwrite homeassistant/#"
              "readwrite tasmota/discovery/#"
              "write cmnd/tasmota/#"
              "read stat/tasmota/#"
              "read tele/tasmota/#"

              "write command/lgoette/#"
              "read state/lgoette/#"
              "read telemetry/lgoette/#"

              "readwrite shellies/%c/announce"
              "read shellies/%c/online"
              "write shellies/%c/command"
              "read shellies/%c/status"
            ];
            hashedPasswordFile = "/var/src/secrets/mosquitto/home_passwd";
          };

          device = {
            acl = [
              "write homeassistant/#"
              "write tasmota/discovery/#"

              "read cmnd/tasmota/%c/#"
              "write stat/tasmota/%c/#"
              "write tele/tasmota/%c/#"

              "read command/lgoette/%c/#"
              "write state/lgoette/%c/#"
              "write telemetry/lgoette/%c/#"

              "write shellies/%c/announce"
              "read shellies/%c/command"
              "write shellies/%c/status"
              "write shellies/%c/online"
            ];
            hashedPasswordFile = "/var/src/secrets/mosquitto/device_passwd";
          };
        };
      }];
    };
  };
}
