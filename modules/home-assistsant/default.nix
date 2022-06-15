{ config, pkgs, lib, ... }:
with lib;
let cfg = config.lgoette.services.home-assistant;

in {
  options.lgoette.services.home-assistant = {
    enable = mkEnableOption "Home-assitant server";
  };

  config = mkIf cfg.enable {

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
              "topic readwrite homeassistant/#"
              "topic readwrite tasmota/discovery/#"
              "topic write cmnd/tasmota/#"
              "topic read stat/tasmota/#"
              "topic read tele/tasmota/#"

              "topic write command/lgoette/#"
              "topic read state/lgoette/#"
              "topic read telemetry/lgoette/#"

              "topic readwrite shellies/%c/announce"
              "topic read shellies/%c/online"
              "topic write shellies/%c/command"
              "topic read shellies/%c/status"
            ];
            hashedPasswordFile = "/var/src/secrets/mosquitto/passwd";
          };

          device = {
            acl = [
              "topic write homeassistant/#"
              "topic write tasmota/discovery/#"

              "pattern read cmnd/tasmota/%c/#"
              "pattern write stat/tasmota/%c/#"
              "pattern write tele/tasmota/%c/#"

              "pattern read command/lgoette/%c/#"
              "pattern write state/lgoette/%c/#"
              "pattern write telemetry/lgoette/%c/#"

              "topic write shellies/%c/announce"
              "topic read shellies/%c/command"
              "topic write shellies/%c/status"
              "topic write shellies/%c/online"
            ];
            hashedPasswordFile = "/var/src/secrets/mosquitto/passwd";
          };
        };
      }];
    };

    # Enable home-assistant service
    services.home-assistant = {
      enable = true;
      config = {

      };
    };
  };
}
