{pkgs, ...}: {
  home.packages = with pkgs; [browsh firefox];
}
