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
        };

        "urban-disclaimer.de" = mkIf cfg.urban-disclaimer {
          # enableACME = true; # -> get a LE certificate
          sslCertificateKey = "/var/src/secrets/ssl/cf_urban-disclaimer.de.key";
          sslCertificate = "/var/src/secrets/ssl/cf_urban-disclaimer.de.pem";
          # addSSL = true;
          root = "/var/www/urban-disclaimer.de";
        };

      };
    };
  };
}
