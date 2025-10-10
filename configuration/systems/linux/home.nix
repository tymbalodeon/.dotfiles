{pkgs, ...}: {
  home.packages = [pkgs.brave];

  imports = [
    ../../home.nix
    ../../modules/ghostty
  ];

  users.linux.enable = true;
}
