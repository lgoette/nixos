inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super: {
  # Custom packages. Will be made available on all machines and used where
  # needed.

  # custom packages
  bukkit-spigot = super.pkgs.callPackage ../packages/bukkit-spigot { };
  minecraft-controller =
    super.pkgs.callPackage ../packages/minecraft-controller { };

  minecraft-backup = super.pkgs.callPackage ../packages/minecraft-backup { };

  # inherit (super.pkgs.callPackages ../packages/unifi { }) unifiLTS unifi5 unifi6 unifi7;
  # unifi = super.pkgs.unifi7;


}
