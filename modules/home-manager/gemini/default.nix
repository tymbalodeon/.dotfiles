{pkgs, ...}: {
  home.packages = [pkgs.lagrange];
  programs.amfora.enable = true;
}
