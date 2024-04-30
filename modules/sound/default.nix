{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.sound;
in {
  options.lgoette.sound = { enable = mkEnableOption "activate sound with pipewire"; };

  config = mkIf cfg.enable {
    # Disabled since pipewire is used
    sound.enable = false;
    hardware.pulseaudio.enable = false;

    security.rtkit.enable = true;

    # Enable sound with pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # Bluetooth configuration
      wireplumber.configPackages = [
        #TODO: Wireplumber profileswitching bug not fixed yet: https://gitlab.freedesktop.org/pipewire/wireplumber/-/issues/617
        # Should be fixed by May 8, 2024
        (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
          		bluez_monitor.properties = {
          			["bluez5.enable-sbc-xq"] = true,
          			["bluez5.enable-msbc"] = true,
          			["bluez5.enable-hw-volume"] = true,
          			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          		}
          	'')
      ];
    };

  };
}
