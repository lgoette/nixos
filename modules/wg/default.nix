{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.wg;
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

    networking.wireguard.interfaces.wg0 = {
      ips = [ "${cfg.ip}/24" ];

      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;
      generatePrivateKeyFile = true;

      peers = [{

        publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";

        allowedIPs = cfg.allowedIPs;

        endpoint = "lamafarm.lasse-goette.de:53115";

        persistentKeepalive = 15;

      }];
    };

  };
}
