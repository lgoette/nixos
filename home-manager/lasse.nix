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
  imports = [ ./modules/neovim.nix ./modules/htop.nix ./modules/shell.nix ];

  programs = {

    zsh = { sessionVariables = { ZDOTDIR = "/home/lasse/.config/zsh"; }; };

  };

  home.packages = with pkgs; [ iperf3 nmap unzip ];

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
