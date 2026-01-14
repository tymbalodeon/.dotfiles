{pkgs, ...}: {
  # TODO: finish setting this up to control external monitor brightness
  home.packages = [pkgs.ddcutil];
  imports = [../../../home-manager];
  music-player.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";
}
