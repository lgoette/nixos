{ pkgs, lib, config, ... }: # , mayniklas
with lib; {
  config = {

    # Home-manager nixpkgs config
    # nixpkgs.config = { 
    #   overlays = [ mayniklas.overlays.mayniklas ];
    # };

    # Install these packages for my user
    home.packages = with pkgs; [
      #pkgs
      iperf3
      nmap
      traceroute
      iftop
      unzip
      mcrcon

      #mayniklas
    ];

  };
}
