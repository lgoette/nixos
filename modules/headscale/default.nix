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
    # TCP 443 -> Headscale is served via HTTPS on port 443

    # Open firewall ports
    networking.firewall = {
      allowedTCPPorts = [ 443 ];
    };

    # Enable headscale service
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 443;
      server_url = "https://${cfg.domain}";
      dns = { baseDomain = "tailnet.local"; };
      settings = { logtail.enabled = false; };
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
