{
  config,
  lib,
  ...
}:
with lib; {
  config = mkIf config.users-nixos-home.enable {
    services.mpd.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";
  };

  options.users-nixos-home.enable =
    mkEnableOption "enables user configuration for \"nixos\" home.nix";
}
