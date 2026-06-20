{pkgs, ...}: {
  home.packages = [pkgs.xrandr];
  imports = [../shell/nushell];
}
