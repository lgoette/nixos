{ config, pkgs, lib, ... }:
with lib;
let cfg = config.lgoette.unifi-controller;
in {

  options.lgoette.unifi-controller = {

    enable = mkEnableOption "UniFi Controller";

    domain = mkOption {
      type = types.str;
      default = "unifi.lounge-rocks.io";
      example = "unifi.lounge-rocks.io";
      description = "(Sub-) domain for unifi.";
    };

  };

  config = mkIf cfg.enable {

    # TCP 80/443 -> NGINX HTTP / HTTPS
    # TCP 8080 -> Required for device communication
    # UDP 3478 -> Unifi STUN port

    # Open firewall ports
    networking.firewall = {
      allowedTCPPorts = [ 80 443 8080 ];
      allowedUDPPorts = [ 3478 ];
    };

    services.unifi = {
      enable = true;
      unifiPackage = (pkgs.callPackages ../../packages/unifi { }).unifi7;
      openFirewall = false;
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        # UniFi Controller
        "${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            client_max_body_size 0;
          '';
          locations."/" = { proxyPass = "https://127.0.0.1:8443"; };
        };
      };
    };

  };
}
