{ lib, buildGoModule, ... }:

buildGoModule rec {

  pname = "minecraft-controller";
  version = "0.0.1";

  src = ./.;
  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

  meta = with lib; {
    description = "web service to start / stop a minecraft server.";
    homepage = "https://github.com/MayNiklas";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ MayNiklas ];
  };

}
