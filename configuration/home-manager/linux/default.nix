{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../brave
    ../rclone
  ];
}
