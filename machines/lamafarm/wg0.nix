{
  config,
  lib,
  pkgs,
  ...
}:
let
  wg0_port = 53115;

  # `allowedIPs` defaults to just the peer's own VPN address; use
  # `extraAllowedIPs` for additionally routed subnets.
  mkPeer =
    {
      ip,
      name,
      publicKey,
      extraAllowedIPs ? [ ],
    }:
    {
      inherit ip name publicKey;
      allowedIPs = [ ip ] ++ extraAllowedIPs;
    };

  wgPeers = map mkPeer [
    {
      ip = "10.11.12.5";
      name = "Raspberry Pi 4 Bonn";
      publicKey = "CQ0eGmaUXekRdYxA45pbmzkcCb5w5Rf9fKV4VkwcBmo=";
      extraAllowedIPs = [ "192.168.176.0/24" ];
    }
    {
      ip = "10.11.12.6";
      name = "Raspberry Pi 4 Koeln";
      publicKey = "fjL1uv+PF1ajKzJt0CDh9LCofPYAtGdqVOWRbC62eC4=";
      extraAllowedIPs = [ "192.168.178.0/24" ];
    }
    {
      ip = "10.11.12.7";
      name = "Raspberry Pi Zero W";
      publicKey = "BhB16enX+GWBjX9NKj1+sScpTylm106SAfbw2wJ/pHg=";
    }
    {
      ip = "10.11.12.8";
      name = "VM Minecraft Server";
      publicKey = "WzD13AnLkv8oZUfsUrQySUFKfCy9fY6zDkYVwnwd6wQ=";
    }
    {
      ip = "10.11.12.100";
      name = "Thinkpad Linux";
      publicKey = "07/aJQKEziJdj6UTpbUNWAEEnpugtZ61stoM29sfIGQ=";
    }
    {
      ip = "10.11.12.101";
      name = "Samsung Galaxy S10";
      publicKey = "dOXyHemzCQJlw0L3j9P5Ue4SrdttJi8k7/Q1ifK4HhY=";
    }
    {
      ip = "10.11.12.102";
      name = "Thinkpad Windows";
      publicKey = "sISbItjlwv9VCe5ZmOFa8irsMmiDgj7cy+aC+Do7mRQ=";
    }
    {
      ip = "10.11.12.203";
      name = "IoT Buzzer";
      publicKey = "qfStJLiGXGuK5Gh80XE09ceY7f75/tTDA0sTVSZqGA4=";
    }
    {
      ip = "10.11.12.204";
      name = "GL.iNet Router";
      publicKey = "tP8n9Ux+wb+Z3laLvGQ0Y6n68aw/wggvA2VoVyf8HE8=";
      extraAllowedIPs = [ "192.168.78.0/24" ];
    }
    {
      ip = "10.11.12.223";
      name = "ChrisPk Laptop";
      publicKey = "C5I0d+OEkdlyMQbQqW2Peg12ZqO+G4jhxIvnZk11wTQ=";
    }
    {
      ip = "10.11.12.224";
      name = "ChrisPk Pi";
      publicKey = "bo0Y3aXF3ee61C8GWA18z+inAdYzNTsqUqrjRaR672E=";
    }
  ];
in
{

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = 1;
    # "net.ipv6.conf.all.proxy_ndp" = 1;
  };

  networking = {

    firewall = {
      allowedUDPPorts = [ wg0_port ];
    };

    wireguard.interfaces.wg0 = {

      ips = [ "10.11.12.1/24" ];
      listenPort = wg0_port;
      mtu = 1412;
      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;
      generatePrivateKeyFile = true;

      # Minecraft server port forwarding via wireguard interface (no port needs to be opened on the host firewall)
      # postSetup = ''
      #   ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 5.252.227.28 -p tcp --dport 25565 -j DNAT --to-destination 10.11.12.8
      #   ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 5.252.227.28 -p udp --dport 25565 -j DNAT --to-destination 10.11.12.8
      #   ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 5.252.227.28 -p tcp --dport 25564 -j DNAT --to-destination 10.11.12.8:22
      # '';

      # postShutdown = ''
      #   ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -d 5.252.227.28 -p tcp --dport 25565 -j DNAT --to-destination 10.11.12.8
      #   ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -d 5.252.227.28 -p udp --dport 25565 -j DNAT --to-destination 10.11.12.8
      #   ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -d 5.252.227.28 -p tcp --dport 25564 -j DNAT --to-destination 10.11.12.8:22
      # '';

      # Derived from wgPeers: WireGuard only needs publicKey + allowedIPs.
      peers = map (p: { inherit (p) publicKey allowedIPs; }) wgPeers;

    };
  };

  # `wgg` maps peer public keys to friendly names using the file below.
  environment.systemPackages = [ pkgs.wg-friendly-peer-names ];

  # Friendly-name database read by `wgg` (wg-friendly-peer-names),
  # generated from the same wgPeers list to keep it in sync.
  environment.etc."wireguard/peers".text = lib.concatMapStrings (
    p: "# ${p.ip}\n${p.publicKey}:${p.name}\n\n"
  ) wgPeers;
}
