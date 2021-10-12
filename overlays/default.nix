self: super: {

  # custom packages
  bukkit-spigot = super.pkgs.callPackage ../packages/bukkit-spigot { };
  dynmap = super.pkgs.callPackage ../packages/dynmap { };

  # override with newer version from nixpkgs-unstable (home-manager related)
  chromium = self.unstable.chromium;
  discord = self.unstable.discord;
  firefox = self.unstable.firefox;
  obs-studio = self.unstable.obs-studio;
  signal-desktop = self.unstable.signal-desktop;
  spotify = self.unstable.spotify;
  youtube-dl = self.unstable.youtube-dl;
}
