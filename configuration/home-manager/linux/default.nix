{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../brave
    ../mpv
    ../rclone
    ../storage
  ];
}
