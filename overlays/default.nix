self: super: {

  # custom packages
  bukkit-spigot = super.pkgs.callPackage ../packages/bukkit-spigot { };
  minecraft-controller =
    super.pkgs.callPackage ../packages/minecraft-controller { };

  # inherit (super.pkgs.callPackages ../packages/unifi { }) unifiLTS unifi5 unifi6 unifi7;
  # unifi = super.pkgs.unifi7;

}
