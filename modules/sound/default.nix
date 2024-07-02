{ lib, pkgs, config, flake-self, ... }:
with lib;
let cfg = config.lgoette.sound;
in {
  options.lgoette.sound = {
    enable = mkEnableOption "Activate sound with pipewire";
    pro-audio = mkEnableOption "Use low latency audio setup with jack instead of pipewire and realtime kernel.";
  };

  # import additional modules from flake inputs
  imports = [
    flake-self.inputs.musnix.nixosModules.musnix
  ];

  config = mkIf cfg.enable (mkMerge [

    # This block is always enabled
    {
      # Disabled since pipewire or jack is used
      sound.enable = false;
      hardware.pulseaudio.enable = false;
    }

    # if pro-audio is enabled
    (mkIf cfg.pro-audio {

      # Enable sound with jack
      services.jack = {
        jackd.enable = true;
        # support ALSA only programs via ALSA JACK PCM plugin
        alsa.enable = false;
        # support ALSA only programs via loopback device (supports programs like Steam)
        loopback = {
          enable = true;
          # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
          #dmixConfig = ''
          #  period_size 2048
          #'';
        };
      };

      # Prepare system for realtime audio
      musnix = {
        enable = true;
        kernel.realtime = true;
        ffado.enable = false; # Firewire drivers
        rtcqs.enable = true; # Commandline tool for checking configuration

        # magic to me
        rtirq = {
          # highList = "snd_hrtimer";
          resetAll = 1;
          prioLow = 0;
          enable = true;
          nameList = "rtc0 snd";
        };
      };

      # Sollte durch Musnix gesetzt worden sein
      # powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

    })

    # if pro-audio is not enabled
    (mkIf (!cfg.pro-audio) {

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
          (pkgs.writeTextDir
            "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua"
            "	bluez_monitor.properties = {\n		[\"bluez5.enable-sbc-xq\"] = true,\n		[\"bluez5.enable-msbc\"] = true,\n		[\"bluez5.enable-hw-volume\"] = true,\n		[\"bluez5.headset-roles\"] = \"[ hsp_hs hsp_ag hfp_hf hfp_ag ]\"\n	}\n")
        ];
      };

    })

  ]);
}
