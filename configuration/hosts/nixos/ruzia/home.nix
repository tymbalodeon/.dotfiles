{pkgs, ...}: {
  home.packages = [pkgs.ddcutil];

  imports = [
    ../../../home-manager
    ../../../home-manager/kitty
    ../../../home-manager/music-player
  ];

  kitty.fontSize = 12.0;
  music-player.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";
}
