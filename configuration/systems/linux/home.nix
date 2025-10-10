{pkgs, ...}: {
  home.packages = [pkgs.brave];

  imports = [
    ../../home.nix
    ../../modules/ghostty
  ];
}
