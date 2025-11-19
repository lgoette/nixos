{
  config,
  lib,
  ...
}:
let
  cfg = config.lgoette.tor-client;
in
{
  options.lgoette.tor-client = {
    enable = lib.mkEnableOption "enable tor client options";
  };

  config = lib.mkIf cfg.enable {
    services.tor = {
      enable = true;
      torsocks.enable = true;
      client.enable = true;
      client.dns.enable = true;
    };
  };
}
