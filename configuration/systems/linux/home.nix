{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../common/home.nix
    ../../modules/brave
    ../../modules/ghostty
    ../../modules/rclone
  ];
}
