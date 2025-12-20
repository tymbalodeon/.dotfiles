{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../../home-manager/brave
    ../../home-manager/rclone
    ../home.nix
  ];
}
