{pkgs, ...}: {
  programs.taskwarrior = {
    colorTheme = "dark-16";
    enable = true;
    package = pkgs.taskwarrior3;
  };
}
