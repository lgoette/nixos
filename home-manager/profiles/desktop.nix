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

    # Sctivate Trayscale tray icon
    systemd.user.services.trayscale = {
      Unit = {
        Description = "Trayscale tray icon";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.trayscale}/bin/trayscale --hide-window";
        Restart = "on-failure";
        Environment = "TRAY_DEBUG=1";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
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
      parsec-bin
      # barrier # TODO: Keyboard is us instead of de when starting input-leap
      # input-leap # Fails to build
      yubioath-flutter

      # Kde
      kdePackages.dolphin
      kdePackages.kate
      kdePackages.ark
      kdePackages.kdeconnect-kde
      kdePackages.krfb
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
      croc
      android-tools
      scrcpy
      screenfetch

      # Uni
      pomodoro-gtk
      gnumake
      gcc
      anki-bin
      texliveFull
      libusb1

      #mayniklas
      mayniklas.drone-gen
    ];

  };
}
