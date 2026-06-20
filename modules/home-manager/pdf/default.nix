{pkgs, ...}: {
  home.packages = [
    pkgs.kdePackages.okular
  ];

  programs.zathura = {
    enable = true;

    options = {
      selection-clipboard = "clipboard";
      recolor = true;
    };
  };
}
