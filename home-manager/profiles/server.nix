{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    # Install these packages for my user
    home.packages = with pkgs; [
      #pkgs
      iperf3
      nmap
      traceroute
      unzip
      mcrcon

      #mayniklas
      mayniklas.vs-fix
    ];

  };
}
