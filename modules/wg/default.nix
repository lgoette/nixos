{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.lgoette.wg;
  publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
in {
  options.lgoette.wg = {
    enable = mkEnableOption "activate wireguard";
    ip = mkOption {
      type = types.str;
      default = "10.88.88.1";
      example = "10.88.88.20";
    };
    allowedIPs = mkOption {
      type = with types; listOf str;
      default = [ "10.88.88.0/24" ];
      description = ''
        List of IP (v4 or v6) addresses with CIDR masks from
        which this peer is allowed to send incoming traffic and to which
        outgoing traffic for this peer is directed. The catch-all 0.0.0.0/0 may
        be specified for matching all IPv4 addresses, and ::/0 may be specified
        for matching all IPv6 addresses.'';
    };
  };

  config = mkIf cfg.enable {

    networking.interfaces.ens192.ipv4.routes = [{
      address = "5.45.108.206";
      prefixLength = 32;
      via = "192.168.20.1";
      options = { metric = "0"; };
    }];

    networking.wireguard.interfaces.wg0 = {

      ips = [ "${cfg.ip}/24" ];

      # Path to the private key file
      privateKeyFile = "/var/src/secrets/wireguard/private";

      peers = [{
        inherit publicKey; # set publicKey to the publicKey we've defined above
        allowedIPs = cfg.allowedIPs;
        endpoint = "lamafarm.lasse-goette.de:53115";
        persistentKeepalive = 25;
      }];
    };

  };
}
