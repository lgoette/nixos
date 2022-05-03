{ config, lib, pkgs, ... }:
let wg0_port = 53115;
in {

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = 1;
    # "net.ipv6.conf.all.proxy_ndp" = 1;
  };

  networking = {

    firewall = { allowedUDPPorts = [ wg0_port ]; };

    interfaces.wg0 = { mtu = 1412; };

    wireguard.interfaces.wg0 = {

      ips = [ "10.11.12.1/24" ];
      listenPort = wg0_port;
      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 5.45.108.206 -p tcp --dport 25565 -j DNAT --to-destination 10.11.12.8
        ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 5.45.108.206 -p udp --dport 25565 -j DNAT --to-destination 10.11.12.8
        ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 5.45.108.206 -p tcp --dport 25564 -j DNAT --to-destination 10.11.12.8:22
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -d 5.45.108.206 -p tcp --dport 25565 -j DNAT --to-destination 10.11.12.8
        ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -d 5.45.108.206 -p udp --dport 25565 -j DNAT --to-destination 10.11.12.8
        ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -d 5.45.108.206 -p tcp --dport 25564 -j DNAT --to-destination 10.11.12.8:22
      '';

      peers = [

        # 10.11.12.5
        {
          publicKey = "CQ0eGmaUXekRdYxA45pbmzkcCb5w5Rf9fKV4VkwcBmo=";
          allowedIPs = [ "10.11.12.5" "192.168.176.0/24" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.6
        {
          publicKey = "fjL1uv+PF1ajKzJt0CDh9LCofPYAtGdqVOWRbC62eC4=";
          allowedIPs = [ "10.11.12.6" "192.168.178.0/24" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.8
        {
          publicKey = "5KIvDXqEpt/bDd0pao0CrnaZTeZtYBtGq//bSjHScDY=";
          allowedIPs = [ "10.11.12.8" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.100
        {
          publicKey = "07/aJQKEziJdj6UTpbUNWAEEnpugtZ61stoM29sfIGQ=";
          allowedIPs = [ "10.11.12.100" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.101
        {
          publicKey = "dOXyHemzCQJlw0L3j9P5Ue4SrdttJi8k7/Q1ifK4HhY=";
          allowedIPs = [ "10.11.12.101" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.102                                                                             
        {
          publicKey = "sISbItjlwv9VCe5ZmOFa8irsMmiDgj7cy+aC+Do7mRQ=";
          allowedIPs = [ "10.11.12.102" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.203
        {
          publicKey = "qfStJLiGXGuK5Gh80XE09ceY7f75/tTDA0sTVSZqGA4=";
          allowedIPs = [ "10.11.12.203" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.204
        {
          publicKey = "tP8n9Ux+wb+Z3laLvGQ0Y6n68aw/wggvA2VoVyf8HE8=";
          allowedIPs = [ "10.11.12.204" "192.168.78.0/24" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.223
        {
          publicKey = "C5I0d+OEkdlyMQbQqW2Peg12ZqO+G4jhxIvnZk11wTQ=";
          allowedIPs = [ "10.11.12.223" ];
          # persistentKeepalive = 15;
        }

        # 10.11.12.224
        {
          publicKey = "bo0Y3aXF3ee61C8GWA18z+inAdYzNTsqUqrjRaR672E=";
          allowedIPs = [ "10.11.12.224" ];
          # persistentKeepalive = 15;
        }

      ];

    };
  };
}
