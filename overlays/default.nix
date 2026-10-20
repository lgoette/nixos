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
  claude-sandbox = super.pkgs.callPackage ../packages/claude-sandbox { };
  # Built from nixpkgs-stable for the same reason as carla below: the merged
  # bundle gets dlopen'ed into the carla process, so the cairo/pixman the UI
  # pulls in must link the same glibc carla already has loaded. Built against
  # unstable, opening the UI fails with "Failed to load UI binary: version
  # `GLIBC_ABI_GNU2_TLS' not found (required by libpixman-1.so.0)".
  # This pins no version: both packages fetch their own pinned sources, so
  # stable vs. unstable only decides which libraries they link against.
  neural-amp-modeler-lv2 = nixpkgs-stable.callPackage ../packages/neural-amp-modeler-lv2 { };
  # Must merge against our own neural-amp-modeler-lv2 (0.2.3): the UI drives
  # port index 6 (quality_scale), which nixpkgs' older release does not have.
  neural-amp-modeler-ui = nixpkgs-stable.callPackage ../packages/neural-amp-modeler-ui {
    inherit (self) neural-amp-modeler-lv2;
  };

  # inherit (super.pkgs.callPackages ../packages/unifi { }) unifiLTS unifi5 unifi6 unifi7;
  # unifi = super.pkgs.unifi7;

  # packages from nixpkgs-stable
  # yabridge must come from the same nixpkgs as carla: its libyabridge-*.so
  # gets dlopen'ed into the carla process, so both need the same glibc.
  inherit (nixpkgs-stable)
    carla
    yabridge
    yabridgectl
    ;

  # downgrade mixxx to 2.4.1
  mixxx =
    (import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/05bbf675397d5366259409139039af8077d695ce.tar.gz";
      sha256 = "sha256:1r26vjqmzgphfnby5lkfihz6i3y70hq84bpkwd43qjjvgxkcyki0";
    }) { inherit system; }).mixxx;

}
