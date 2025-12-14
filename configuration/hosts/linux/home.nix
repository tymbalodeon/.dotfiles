{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../../home-manager/brave
    ../../home-manager/ghostty
    ../../home-manager/rclone
    ../home.nix
  ];
}
