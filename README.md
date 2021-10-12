# nixos

### common commands:

```bash
# basic flake check
nix flake check

# update flake.lock
nix flake update      

# build / check config without applying
nix build -v '.#nixosConfigurations.minecraft.config.system.build.toplevel' 

# switch to new config
sudo nixos-rebuild switch -v --show-trace --flake .

# build flake app
nix build build .#bukkit-spigot

# run flake app
nix rub .#bukkit-spigot

# run flake app externally
nix run 'github:mayniklas/nixos#owncast'

# run flake app
nix run nixpkgs#python39 -- --version  

# run nix-shell with nodejs-14
nix-shell -p nodejs-14_x 

# run app in nix-shell
nix-shell -p nodejs-14_x --run "node -v"

# delete nix store
nix-collect-garbage -d

# use auto formatter on flake.nix
nixfmt flake.nix
```