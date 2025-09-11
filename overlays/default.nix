inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super:
let
  system = super.system;
  nixpkgs-stable = (import inputs.nixpkgs-stable { inherit system; });
in
{
  # Custom packages. Will be made available on all machines and used where
  # needed.

  # custom packages
  bukkit-spigot = super.pkgs.callPackage ../packages/bukkit-spigot { };
  minecraft-controller = super.pkgs.callPackage ../packages/minecraft-controller { };

  minecraft-backup = super.pkgs.callPackage ../packages/minecraft-backup { };

  # inherit (super.pkgs.callPackages ../packages/unifi { }) unifiLTS unifi5 unifi6 unifi7;
  # unifi = super.pkgs.unifi7;

  # packages from nixpkgs-stable
  inherit (nixpkgs-stable)
    carla
    ;

  # downgrade mixxx to 2.4.1
  mixxx =
    (import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/05bbf675397d5366259409139039af8077d695ce.tar.gz";
      sha256 = "sha256:1r26vjqmzgphfnby5lkfihz6i3y70hq84bpkwd43qjjvgxkcyki0";
    }) { inherit system; }).mixxx;

}
