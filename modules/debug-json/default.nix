{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lgoette.debug-json;
in {
  options = {
    lgoette.debug-json = {
      enable = mkEnableOption "debug Json File";
      data = mkOption {
        type = let
          minecraftOperator = (types.submodule ({ name, ... }: {
            options = {
              uuid = mkOption {
                type = types.strMatching
                  "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";
                description = "Minecraft UUID";
              };
              level = mkOption {
                type = types.int;
                description = "Operator Level";
              };
              bypassesPlayerLimit = mkOption {
                type = types.bool;
                default = false;
                description = "Player can join even if playerlimit is reached";
              };
            };
          }));
        in types.attrsOf minecraftOperator;
        default = { };
        description = ''
          players with ops, only has an effect when
          <option>services.minecraft-server.declarative</option> is
          <literal>true</literal>
          This is a mapping from Minecraft username to UUID, op-level and bypassesPlayerLimit option.
          You can use <link xlink:href="https://mcuuid.net/"/> to get a
          Minecraft UUID for a username.
        '';
        example = literalExample ''
          {
              username1 = { 
                  uuid="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                  level=4;
                  bypassesPlayerLimit=true;
              };
              username2 = { 
                  uuid="yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
                  level=2;
                  bypassesPlayerLimit=false;
              };
          };
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc = {
      # Creates /etc/debug-json
      debug-json = {
        text = builtins.toJSON (mapAttrsToList (n: v: {
          name = n;
          uuid = v.uuid;
          level = v.level;
          bypassesPlayerLimit = v.bypassesPlayerLimit;
        }) cfg.data);

        # The UNIX file mode bits
        mode = "0440";
      };
    };
  };
}
