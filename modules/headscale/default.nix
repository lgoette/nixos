{ config, pkgs, lib, flake-self, ... }:
with lib;
let cfg = config.lgoette.headscale-controller;

in {

  imports = [
    flake-self.inputs.headplane.nixosModules.headplane
  ];

  options.lgoette.headscale-controller = {

    enable = mkEnableOption "enable headscale control server";

    headscale-domain = mkOption {
      type = types.str;
      default = "headscale.lasse-goette.de";
      example = "headscale.example.com";
      description = "(Sub-) domain for headscale.";
    };

    headplane-domain = mkOption {
      type = types.str;
      default = "tailscale.lasse-goette.de";
      example = "headplane.example.com";
      description = "(Sub-) domain for headplane ui.";
    };

  };

  config = mkIf cfg.enable {
    # TCP 8443 -> Headscale is served via HTTPS on port 8080

    # Open firewall ports
    networking.firewall = {
      allowedTCPPorts = [ config.services.headscale.port config.services.headplane.settings.server.port ];
    };

    # Enable headscale service
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 4443;
      settings = {
        server_url = "https://${cfg.headscale-domain}";
        dns = {
          base_domain = "tailnet.local";
          nameservers.global = [ "1.1.1.1" "8.8.8.8"];
        };
      };
    };

    # enable headplane (headscale ui)
    services.headplane = {
      enable = true;
      # agent = {}; # Agent später noch testen um mehr Infos über Nodes zu bekommen
      settings = {
        server = {
          host = "0.0.0.0";
          port = 3000;
          # cookie_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
          cookie_secure = true;
        };
        headscale = {
          url = "https://${cfg.headscale-domain}";
          # config_path = ; # Hier kann man wohl irgendwie ne Headscale Konfiguration erstellen und so? Is das wichtig? https://github.com/tale/headplane/blob/main/docs/Nix.md
          config_strict = true;
        };
        integration.proc.enabled = true;
        # TODO: Host ocid issuer and set ocid settings here:
        # oidc = {
        #   issuer = "https://oidc.example.com";
        #   client_id = "headplane";
        #   client_secret_path = "${CREDENTIALS_DIRECTORY}/oidc_client_secret"
        #   disable_api_key_login = true;
        #   # Might needed when integrating with Authelia.
        #   token_endpoint_auth_method = "client_secret_basic";
        #   headscale_api_key = "xxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
        #   redirect_uri = "https://oidc.example.com/admin/oidc/callback";
        # };
      };
    };

    # Setup NGINX to proxy requests to headscale
    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.headscale-domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass =
              "http://127.0.0.1:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
        "${cfg.headplane-domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass =
              "http://127.0.0.1:${toString config.services.headplane.settings.server.port}";
            proxyWebsockets = true;
          };
        };
      };
    };

    # Enable the headscale CLI tool
    environment.systemPackages = [ config.services.headscale.package ];

  };

}
