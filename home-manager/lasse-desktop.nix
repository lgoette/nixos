{ config, pkgs, ... }: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lasse";
  home.homeDirectory = "/home/lasse";

  # Allow "unfree" licenced packages
  nixpkgs.config = { allowUnfree = true; };

  # Imports
  imports = [
    ./modules/neovim.nix
    ./modules/htop.nix
    ./modules/shell.nix
    ./modules/vscode.nix
  ];

  programs = {

    zsh = { sessionVariables = { ZDOTDIR = "/home/lasse/.config/zsh"; }; };

  };

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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
