{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.user.lasse.home-manager;
in
{

  options.lgoette.user.lasse.home-manager = {
    enable = mkEnableOption "activate headless home-manager profile for lasse";
  };

  config = mkIf cfg.enable {

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.useUserPackages = true;

    home-manager.users.lasse = {

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      programs.command-not-found.enable = true;
      home.username = "lasse";
      home.homeDirectory = "/home/lasse";

      # Allow "unfree" licenced packages
      nixpkgs.config = { allowUnfree = true; };

      programs = {

        zsh = { sessionVariables = { ZDOTDIR = "/home/lasse/.config/zsh"; }; };

      };

      # Install these packages for my user

      home.packages = with pkgs; [
        #pkgs
        iperf3
        nmap
        unzip
        mcrcon

        #mayniklas
        mayniklas.drone-gen
        mayniklas.vs-fix
      ];

      imports = [ ./modules/neovim.nix ./modules/htop.nix ./modules/shell.nix ];

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      home.stateVersion = "21.05";

    };

  };
}

