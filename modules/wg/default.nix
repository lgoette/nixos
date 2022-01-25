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

    networking.wg-quick.interfaces.wg0 = {

      address = [ "${cfg.ip}/24" ];

      postUp = ''
        wg set wg0 peer ${publicKey} persistent-keepalive 25
        ip route add 192.168.5.0/24 via 192.168.20.1 dev ens192 metric 0
        ip route add 10.88.88.0/24 via 192.168.20.1 dev ens192 metric 0
      '';

      postDown = ''
        ip route del 192.168.5.0/24 via 192.168.20.1 dev ens192 metric 0
        ip route del 10.88.88.0/24 via 192.168.20.1 dev ens192 metric 0
      '';

      # Path to the private key file
      privateKeyFile = "/var/src/secrets/wireguard/private";

      peers = [{
        inherit publicKey; # set publicKey to the publicKey we've defined above

        allowedIPs = cfg.allowedIPs;

        endpoint = "lamafarm.lasse-goette.de:53115";

        # Use postUp instead of this setting because otherwise it doesn't auto
        # connect to the peer, apparently that doesn't happen if the private
        # key is set after the PersistentKeepalive setting which happens if
        # we load it from a file
        #persistentKeepalive = 25;
      }];
    };

  };
}
