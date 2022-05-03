{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.nginx;
in {

  options.lgoette.nginx = {
    enable = mkEnableOption "nginx";
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

      };
    };
  };
}
