{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.shell;
in {
  options.lasse.programs.shell.enable = mkEnableOption "enable shell with zsh";

  config = mkIf cfg.enable {

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      autocd = true;
      dotDir = ".config/zsh";

      initExtra = ''
        [[ -f ~/.profile ]] && . ~/.profile

        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        # revert last n commits
        grv() {
          git reset --soft HEAD~$1
        }

        # if user is root
        if [[ $UID == 0 || $EUID == 0 ]]; then
          PROMPT="%B%F{red}%n@%m: %F{blue}%~ > %f%b" # TODO: Wie kann ich dem root User auch diese shell geben?

        # if user is in nix-shell
        elif [[ -n "$IN_NIX_SHELL" ]]; then
          PROMPT="%B%F{yellow}nix-shell: %F{blue}%~ > %f%b"

        # default shell
        else
          PROMPT="%B%F{green}%n@%m: %F{blue}%~/ > %f%b"
        fi
      '';

      history = {
        expireDuplicatesFirst = true;
        ignoreSpace = false;
        save = 15000;
        share = true;
      };

      plugins = [
        {
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
      ];

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
  };
}
