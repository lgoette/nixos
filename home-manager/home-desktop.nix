{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.user.lasse.home-manager;

in {

  options.lgoette.user.lasse.home-manager = {
    desktop = mkEnableOption "activate desktop home-manager profile for lasse";
  };

  config = mkIf cfg.desktop {

    lgoette.user.lasse.home-manager.enable = true;

    home-manager.users.lasse = {

      # Imports
      imports = [ ./modules/vscode.nix ];

      home.packages = with pkgs; [
        arduino
        atom
        blender
        chromium
        discord
        dolphin
        element
        firefox
        gcc
        gimp
        gparted
        htop
        iperf3
        libreoffice
        nmap
        obs-studio
        postman
        remmina
        signal-desktop
        simple-scan
        spotify
        synology-drive-client
        tdesktop
        thunderbird-bin
        unzip
        vlc
        youtube-dl
        zoom-us
      ];

    };
  };
}
