{ lib, pkgs, config, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    dotDir = ".config/zsh";
    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      
      # revert last n commits
      grv() {
        git reset --soft HEAD~$1
      }
    '';
    history = {
      expireDuplicatesFirst = true;
      ignoreSpace = false;
      save = 15000;
      share = true;
    };
    plugins = [{
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
    }];
    shellAliases = rec {
      # nix
      nixos-rebuild =
        "${pkgs.nixos-rebuild}/bin/nixos-rebuild --use-remote-sudo";
    };
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.jq.enable = true;

  programs.bat = {
    enable = true;
    config = { theme = "base16"; };
  };
}
