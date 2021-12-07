{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lgoette.debug-json;
in {
    options = {
        lgoette.debug-json = {
            enable = mkEnableOption "debug Json File";
            data = mkOption {
                default = {};
                description = ''
                players with ops, only has an effect when
                <option>services.minecraft-server.declarative</option> is
                <literal>true</literal>
                This is a mapping from Minecraft usernames to UUIDs.
                You can use <link xlink:href="https://mcuuid.net/"/> to get a
                Minecraft UUID for a username.
                '';
                example = literalExample ''
                {
                    username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                    username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
                };
                '';
            };
        };
    };
    
    config = mkIf cfg.enable {
        environment.etc = {
            # Creates /etc/debug-json
            debug-json = {
                text = builtins.toJSON
                (mapAttrsToList (n: v: { name = n; uuid = v.uuid; level = v.level; bypassesPlayerLimit = v.bypassesPlayerLimit; }) cfg.data);

                # The UNIX file mode bits
                mode = "0440";
            };
        };
    };
}