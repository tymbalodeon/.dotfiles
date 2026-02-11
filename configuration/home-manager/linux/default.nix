{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../mpv
    ../rclone
    ../storage
    ../zen-browser
  ];
}
