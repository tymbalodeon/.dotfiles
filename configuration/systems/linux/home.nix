{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../../home.nix
    ../../modules/ghostty
  ];
}
