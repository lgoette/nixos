{ config, lib, pkgs, ... }: {

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = 1;
    # "net.ipv6.conf.all.proxy_ndp" = 1;
  };

  networking = {

    interfaces.wg0 = { mtu = 1412; };

    wireguard.interfaces.wg0 = {

      ips = [ "10.11.12.7/24" ];
      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
      '';

      peers = [

        # 10.11.12.5 (noch 7)
        {
          publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
          allowedIPs = [ "10.11.12.1" "192.168.176.0/24" ];
          persistentKeepalive = 15;
          Endpoint = "lamafarm.lasse-goette.de:53115";
        }

      ];

    };
  };
}
