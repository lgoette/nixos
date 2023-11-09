{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    imports = [ vscode-server.nixosModules.home ];
    
    # Visual Studio Code Server support
    services.vscode-server.enable = true;

    # Install these packages for my user
    home.packages = with pkgs; 
      with pkgs.mayniklas; [
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
