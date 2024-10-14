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
      metric = 650;
      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;
      preSetup =
        let
          script = pkgs.writeShellScriptBin "pre-script" ''
            echo "hello world!"
          '';
        in
        "${script}/bin/pre-script";
      #   # Try to access the DNS for up to 300s
      #   for i in {1..300}; do
      #     ${pkgs.iputils}/bin/ping -c1 'lamafarm.lasse-goette.de' && break
      #     echo "Attempt $i: DNS still not available"
      #     sleep 1s
      #   done
      # ''; # TODO: Das hält den boot um 5 Minuten auf, das muss anders gemacht werden

      peers = [

        # 10.11.12.100
        {
          publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
          allowedIPs = [
            "10.11.12.1"
            "10.11.12.5"
            "10.11.12.6"
            "10.11.12.7"
            "10.11.12.8"
            "10.11.12.101"
            "10.11.12.200"
            "10.11.12.204"
            "192.168.176.0/24"
            "192.168.178.0/24"
            "192.168.78.0/24"
          ];
          persistentKeepalive = 15;
          endpoint = "lamafarm.lasse-goette.de:53115";
        }

      ];

    };
  };

  systemd.services."wireguard-wg0-peer-qBxrUEGSaf-P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA\\x3d" =
    {
      # TODO: Scheint noch nicht zu funktionieren (Das Script wird auch nicht so ganz angenommen)
      # after = [ "network.target" ]; # Irgendwie startet Wireguard gar nicht mehr :/
      serviceConfig.ExecStartPre = pkgs.writeScriptBin
        "wireguard-wg0-peer-qBxrUEGSaf-P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA" ''
        # Try to access the DNS for up to 300s
        for i in {1..300}; do
          ${pkgs.iputils}/bin/ping -c1 'lamafarm.lasse-goette.de' && break
          echo "Attempt $i: DNS still not available"
          sleep 1s
        done
      '';
    };
}
