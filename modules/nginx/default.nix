{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.nginx;
in
{

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

      serverNamesHashBucketSize = 64;

      virtualHosts = {

        "workshop.lasse-goette.de" = mkIf cfg.workshop {
          # enableACME = true; # -> get a LE certificate
          sslCertificateKey =
            "/var/src/secrets/ssl/cf_workshop.lasse-goette.de.key";
          sslCertificate =
            "/var/src/secrets/ssl/cf_workshop.lasse-goette.de.pem";
          onlySSL = true;
          root = "/var/www/workshop.lasse-goette.de";

          locations."~*\.(css|png|jpg|jpeg)$" = {
            extraConfig = ''
              access_log off;
              expires max;
            '';
          };

          extraConfig = ''
            # https://www.cloudflare.com/ips

            # IPv4
            set_real_ip_from 173.245.48.0/20;
            set_real_ip_from 103.21.244.0/22;
            set_real_ip_from 103.22.200.0/22;
            set_real_ip_from 103.31.4.0/22;
            set_real_ip_from 141.101.64.0/18;
            set_real_ip_from 108.162.192.0/18;
            set_real_ip_from 190.93.240.0/20;
            set_real_ip_from 188.114.96.0/20;
            set_real_ip_from 197.234.240.0/22;
            set_real_ip_from 198.41.128.0/17;
            set_real_ip_from 162.158.0.0/15;
            set_real_ip_from 104.16.0.0/13;
            set_real_ip_from 104.24.0.0/14;
            set_real_ip_from 172.64.0.0/13;
            set_real_ip_from 131.0.72.0/22;

            # IPv6
            set_real_ip_from 2400:cb00::/32;
            set_real_ip_from 2606:4700::/32;
            set_real_ip_from 2803:f800::/32;
            set_real_ip_from 2405:b500::/32;
            set_real_ip_from 2405:8100::/32;
            set_real_ip_from 2a06:98c0::/29;
            set_real_ip_from 2c0f:f248::/32;

            real_ip_header CF-Connecting-IP;
            # real_ip_header X-Forwarded-For;

            # Generated at Tue May  3 21:22:55 CEST 2022
          '';
        };

        "urban-disclaimer.de" = mkIf cfg.urban-disclaimer {
          # enableACME = true; # -> get a LE certificate
          sslCertificateKey = "/var/src/secrets/ssl/cf_urban-disclaimer.de.key";
          sslCertificate = "/var/src/secrets/ssl/cf_urban-disclaimer.de.pem";
          onlySSL = true;
          root = "/var/www/urban-disclaimer.de";
          extraConfig = ''
            # https://www.cloudflare.com/ips

            # IPv4
            set_real_ip_from 173.245.48.0/20;
            set_real_ip_from 103.21.244.0/22;
            set_real_ip_from 103.22.200.0/22;
            set_real_ip_from 103.31.4.0/22;
            set_real_ip_from 141.101.64.0/18;
            set_real_ip_from 108.162.192.0/18;
            set_real_ip_from 190.93.240.0/20;
            set_real_ip_from 188.114.96.0/20;
            set_real_ip_from 197.234.240.0/22;
            set_real_ip_from 198.41.128.0/17;
            set_real_ip_from 162.158.0.0/15;
            set_real_ip_from 104.16.0.0/13;
            set_real_ip_from 104.24.0.0/14;
            set_real_ip_from 172.64.0.0/13;
            set_real_ip_from 131.0.72.0/22;

            # IPv6
            set_real_ip_from 2400:cb00::/32;
            set_real_ip_from 2606:4700::/32;
            set_real_ip_from 2803:f800::/32;
            set_real_ip_from 2405:b500::/32;
            set_real_ip_from 2405:8100::/32;
            set_real_ip_from 2a06:98c0::/29;
            set_real_ip_from 2c0f:f248::/32;

            real_ip_header CF-Connecting-IP;
            # real_ip_header X-Forwarded-For;

            # Generated at Tue May  3 21:22:55 CEST 2022
          '';
        };

      };
    };
  };
}
