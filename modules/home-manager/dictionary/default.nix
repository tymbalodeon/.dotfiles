{pkgs, ...}: {
  home.packages = [pkgs.wordbook];
  imports = [../clipboard];
}
