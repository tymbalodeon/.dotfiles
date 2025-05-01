{pkgs, ...}: {
  home = {
    file.".config/vivid/themes/theme.yml".source = ./themes/theme.yml;
    packages = [pkgs.vivid];
  };
}
