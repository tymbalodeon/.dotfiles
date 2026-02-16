{pkgs, ...}: {
  home.packages = [pkgs.dysk];

  imports = [
    ../mpv
    ../zen-browser
  ];
}
