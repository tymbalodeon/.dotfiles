{pkgs, ...}: {
  home = {
    file.".config/zellij/themes/theme.kdl".source = ./themes/theme.kdl;
    packages = [pkgs.zellij];
  };
}
