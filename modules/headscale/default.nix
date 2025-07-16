{ config, pkgs, lib, ... }:
with lib;
let cfg = config.lgoette.headscale-controller;
in {

  options.lgoette.headscale-controller = {

    enable = mkEnableOption "enable headscale control server";

    domain = mkOption {
      type = types.str;
      default = "tailscale.lasse-goette.de";
      example = "headscale.example.com";
      description = "(Sub-) domain for headscale.";
    };

  };

  config = mkIf cfg.enable {
    # TCP 8443 -> Headscale is served via HTTPS on port 8080

    # Open firewall ports
    networking.firewall = {
      allowedTCPPorts = [ config.services.headscale.port ];
    };

    # Enable headscale service
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 4443;
      settings = {
        server_url = "https://${cfg.domain}";
        dns = {
          base_domain = "tailnet.local";
          nameservers.global = [ "1.1.1.1" "8.8.8.8"];
        };
      };
    };

    # enable headplane (headscale ui)
    services.headplane = {
      enable = true;
      settings = {
        server = {
          host = "0.0.0.0";
          port = 3000;
          # cookie_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
          cookie_secure = true;
        };
        headscale = {
          url = "https://${cfg.domain}";

          config_strict = true;
        };
      };
    };

    # Setup NGINX to proxy requests to headscale
    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass =
              "http://127.0.0.1:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
      };
    };

    # Enable the headscale CLI tool
    environment.systemPackages = [ config.services.headscale.package ];

  };

}
