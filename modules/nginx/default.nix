{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.nginx;
in {

  options.lgoette.nginx = {
    enable = mkEnableOption "nginx";
    workshop = mkEnableOption "workshop site";
    urban-disclaimer = mkEnableOption "urban-disclaimer site";
  };

  config = mkIf cfg.enable {

    # used for LE certificates
    security.acme.defaults.email = "acme@lasse-goette.de";
    # accept LE TOS
    security.acme.acceptTerms = true;

    networking.firewall = { allowedTCPPorts = [ 80 443 ]; };

    # Enable a small Nginx Server
    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      virtualHosts = {

        "workshop.lasse-goette.de" = mkIf cfg.workshop {
          # enableACME = true; # -> get a LE certificate
          sslCertificateKey =
            "/var/src/secrets/ssl/cf_workshop.lasse-goette.de.key";
          sslCertificate =
            "/var/src/secrets/ssl/cf_workshop.lasse-goette.de.pem";
          addSSL = true;
          root = "/var/www/workshop.lasse-goette.de";
          extraConfig = ''
            # https://www.cloudflare.com/ips
            # IPv4
            allow 173.245.48.0/20;
            allow 103.21.244.0/22;
            allow 103.22.200.0/22;
            allow 103.31.4.0/22;
            allow 141.101.64.0/18;
            allow 108.162.192.0/18;
            allow 190.93.240.0/20;
            allow 188.114.96.0/20;
            allow 197.234.240.0/22;
            allow 198.41.128.0/17;
            allow 162.158.0.0/15;
            allow 104.16.0.0/13;
            allow 104.24.0.0/14;
            allow 172.64.0.0/13;
            allow 131.0.72.0/22;
            # IPv6
            allow 2400:cb00::/32;
            allow 2606:4700::/32;
            allow 2803:f800::/32;
            allow 2405:b500::/32;
            allow 2405:8100::/32;
            allow 2a06:98c0::/29;
            allow 2c0f:f248::/32;
            # Generated at Tue May  3 17:03:29 CEST 2022
            deny all; # deny all remaining ips
          '';
        };

        "urban-disclaimer.de" = mkIf cfg.urban-disclaimer {
          # enableACME = true; # -> get a LE certificate
          sslCertificateKey = "/var/src/secrets/ssl/cf_urban-disclaimer.de.key";
          sslCertificate = "/var/src/secrets/ssl/cf_urban-disclaimer.de.pem";
          addSSL = true;
          root = "/var/www/urban-disclaimer.de";
          extraConfig = ''
            # https://www.cloudflare.com/ips
            # IPv4
            allow 173.245.48.0/20;
            allow 103.21.244.0/22;
            allow 103.22.200.0/22;
            allow 103.31.4.0/22;
            allow 141.101.64.0/18;
            allow 108.162.192.0/18;
            allow 190.93.240.0/20;
            allow 188.114.96.0/20;
            allow 197.234.240.0/22;
            allow 198.41.128.0/17;
            allow 162.158.0.0/15;
            allow 104.16.0.0/13;
            allow 104.24.0.0/14;
            allow 172.64.0.0/13;
            allow 131.0.72.0/22;
            # IPv6
            allow 2400:cb00::/32;
            allow 2606:4700::/32;
            allow 2803:f800::/32;
            allow 2405:b500::/32;
            allow 2405:8100::/32;
            allow 2a06:98c0::/29;
            allow 2c0f:f248::/32;
            # Generated at Tue May  3 17:03:29 CEST 2022
            deny all; # deny all remaining ips
          '';
        };

      };
    };
  };
}
