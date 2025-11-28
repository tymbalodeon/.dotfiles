{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../common/home.nix
    ../../modules/brave
    ../../modules/firefox
    ../../modules/ghostty
    ../../modules/rclone
  ];
}
