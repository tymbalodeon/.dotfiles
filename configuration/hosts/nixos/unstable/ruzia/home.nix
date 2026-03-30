{pkgs, ...}: {
  home.packages = [pkgs.ddcutil];

  imports = [
    ../../../../home-manager
    ../../../../home-manager/music-player
    ../../../../home-manager/niri
  ];

  music-player.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";
}
