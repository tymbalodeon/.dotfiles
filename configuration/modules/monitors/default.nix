{pkgs, ...}: {
  home.packages = [pkgs.xrandr];
  imports = [../nushell];
}
