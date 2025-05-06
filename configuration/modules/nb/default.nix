{pkgs, ...}: {
  home.packages = [pkgs.nb];
  imports = [../helix/markdown];
}
