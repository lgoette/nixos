# nixos

### common commands:

```bash
# basic flake check
nix flake check

# update flake.lock -> updates all flake inputs (e.g. system update)
nix flake update

# update a single flake input
nix flake lock --update-input mayniklas

# show contents of flake
nix flake show

# show flake info
nix flake info

# build / check config without applying
nix build -v '.#nixosConfigurations.lamabasis.config.system.build.toplevel' 

# switch to new config
nixos-rebuild --use-remote-sudo switch --flake .

# build flake output
nix build build .#bukkit-spigot

# run flake app
nix run .#bukkit-spigot

# run flake app externally
nix run 'github:mayniklas/nixos#owncast'

# run flake app
nix run nixpkgs#python39 -- --version  

# run nix-shell with nodejs-14
nix-shell -p nodejs-14_x 

# run app in nix-shell
nix-shell -p nodejs-14_x --run "node -v"

# lists all syslinks into the nix store (helpfull for finding old builds that can be deleted)
nix-store --gc --print-roots

# delete unused elements in nix store
nix-collect-garbage

# also delete iterations from boot
nix-collect-garbage -d

# use auto formatter on flake.nix
nix fmt flake.nix
```
