{ pkgs, lib, config, ... }: # , mayniklas
with lib; {
  config = {

    # Home-manager nixpkgs config
    # nixpkgs.config = { 
    #   overlays = [ mayniklas.overlays.mayniklas ];
    # };

    lasse = {
      programs.vscode.enable = true;
      programs.plasma.enable = true;
      programs.direnv.enable = true;
      programs.git.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [

      # Common
      nil
      nfs-utils
      samba
      pavucontrol
      gparted
      unzip
      htop
      iperf3
      nmap
      traceroute
      remmina
      # barrier # TODO: Keyboard is us instead of de when starting input-leap
      input-leap
      yubioath-flutter

      # Kde
      kdePackages.dolphin
      kdePackages.kate
      kdePackages.ark
      kdePackages.kdeconnect-kde
      kdePackages.krfb
      libsForQt5.kpurpose
      kdePackages.kde-gtk-config
      kdePackages.kfind
      kdePackages.calendarsupport
      kdePackages.konsole
      kdePackages.kcalc
      kdePackages.partitionmanager

      # Development
      arduino
      (python3.withPackages
        (ps: with ps; [ pip requests numpy matplotlib jupyter notebook scipy ]))
      # postman
      go

      # Office
      chromium
      firefox
      thunderbird-bin
      libreoffice
      simple-scan
      synology-drive-client
      obsidian
      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_DE

      # Media
      spotify
      vlc
      yt-dlp
      mixxx

      # Comunication
      signal-desktop
      tdesktop
      discord
      element-desktop

      # Creativity
      blender
      gimp

      # Misc
      # cobang
      android-tools
      scrcpy
      screenfetch

      # Uni
      gcc

      #mayniklas
      mayniklas.drone-gen
      mayniklas.vs-fix
    ];

  };
}
