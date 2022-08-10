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
      # -> use our own package
      # unifiPackage = (pkgs.callPackages ../../packages/unifi { }).unifi7;
      # -> use newest package in NixPkgs
      unifiPackage = pkgs.unifi;
      openFirewall = false;
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        # UniFi Controller
        "${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = { return = "403"; };
            "~(/wss|/manage|/login|/status|/templates|/src|/services|/directives|/api)" =
              {
                proxyPass = "https://127.0.0.1:8443";
                extraConfig = ''
                  proxy_set_header Authorization "";
                  proxy_pass_request_headers on;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-Host $server_name;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header X-Forwarded-Ssl on;
                  proxy_http_version 1.1;
                  proxy_buffering off;
                  proxy_redirect off;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "Upgrade";
                '';
              };
          };
        };
      };
    };

  };
}
