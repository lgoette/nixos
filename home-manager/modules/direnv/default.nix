{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.lasse.programs.direnv;
in
{

  options.lasse.programs.direnv = {
    enable = mkEnableOption "activate direnv";
  };

  config = mkIf cfg.enable {

    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        config = {
          global = {
            hide_env_diff = true; # hide annoying diff output
          };
        };
      };

      git = {
        ignores = [ ".direnv/" ];
      };
      vscode = {
        extensions = with pkgs.vscode-extensions; [ mkhl.direnv ];
      };
    };

    # put direnv cache in ~/.cache/direnv instead of ./.direnv
    # this prevents editors from indexing it
    xdg.configFile."direnv/direnvrc".text = ''
      # Set cache dir
      : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          local hash path
          echo "''${direnv_layout_dirs[$PWD]:=$(
              hash="$(sha1sum - <<< "$PWD" | head -c40)"
              path="''${PWD//[^a-zA-Z0-9]/-}"
              echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
          )}"
      }
    '';

  };

}
