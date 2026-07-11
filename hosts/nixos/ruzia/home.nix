{pkgs, ...}: {
  home.packages = [pkgs.ddcutil];

  imports = [
    ../../../modules/home-manager
    ../../../modules/home-manager/audio/music-player
  ];

  music-player.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";
}
