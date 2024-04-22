{ config, lib, pkgs, ... }: {

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = 1;
    # "net.ipv6.conf.all.proxy_ndp" = 1;
  };

  networking = {

    interfaces.wg0 = { mtu = 1412; };

    wireguard.interfaces.wg0 = {
      ips = [ "10.11.12.100/24" ];
      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;
      metric = 650;

      peers = [
        
        # 10.11.12.100
        {
          publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
          allowedIPs = [ "10.11.12.1" "10.11.12.5" "10.11.12.6" "10.11.12.7" "10.11.12.8" "10.11.12.101" "10.11.12.200" "10.11.12.204" "192.168.176.0/24" "192.168.178.0/24" "192.168.78.0/24" ];
          persistentKeepalive = 15;
          endpoint = "lamafarm.lasse-goette.de:53115";
        }

      ];

    };
  };
}
