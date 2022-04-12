self: super: {

  # custom packages
  bukkit-spigot = super.pkgs.callPackage ../packages/bukkit-spigot { };
  minecraft-controller =
    super.pkgs.callPackage ../packages/minecraft-controller { };

}
