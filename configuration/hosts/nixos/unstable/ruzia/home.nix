{pkgs, ...}: {
  home.packages = [pkgs.ddcutil];

  imports = [
    ../../../../home-manager
    ../../../../home-manager/music-player
  ];

  music-player.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";

  user.nbRemotes = [
    "git@github.com:benjaminrosen/notes.git"
    "git@github.com:tymbalodeon/notes.git"
  ];
}
