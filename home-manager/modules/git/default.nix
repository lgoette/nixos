{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.git;
in {
  options.lasse.programs.git.enable = mkEnableOption "enable git";

  config = mkIf cfg.enable {

    programs = {
      git = {
        enable = true;
        ignores = [
          ".vscode/"
          "tags"
          "*.swp"
          # Nix builds
          "result"
          # Core latex/pdflatex auxiliary files
          "*.aux"
          "*.lof"
          "*.log"
          "*.lot"
          "*.fls"
          "*.out"
          "*.toc"
          "*.fmt"
          "*.fot"
          "*.cb"
          "*.cb2"
          ".*.lb"
          # Python
          "__pycache__/"
          "*.py[cod]"
          "*$py.class"
          ".Python"
          "build/"
          "develop-eggs/"
          "dist/"
          # Web
          "node_modules/"
          "bun.lockb"
        ];
        extraConfig = {
          pull.rebase = false;
          init.defaultBranch = "main";
        };
        userEmail = "git@lasse-goette.de";
        userName = "lgoette";
      };
    };
    home.packages = with pkgs; [ pre-commit git-crypt ];

  };
}
