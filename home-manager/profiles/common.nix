{ config, pkgs, lib, flake-self, system-config, ... }:
with lib;
{
  config = {

    lasse = {
      programs.shell.enable = true;
      programs.htop.enable = true;
      programs.neovim.enable = true;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.command-not-found.enable = true;
    home.username = "lasse";
    home.homeDirectory = "/home/lasse";

    # Home-manager nixpkgs config
    nixpkgs.config = { 
      # Allow "unfree" licenced packages
      allowUnfree = true; 
      overlays = [ ];
    };

    programs = {

      zsh = { sessionVariables = { ZDOTDIR = "/home/lasse/.config/zsh"; }; };

    };

    # Include man-pages
    manual.manpages.enable = true;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.11";
  };
}
