{pkgs, ...}: {
  home.packages = [pkgs.brave];

  imports = [
    ../common/home.nix
    ../../modules/ghostty
  ];
}
