{pkgs, ...}: {
  home.packages = [
    pkgs.kdePackages.okular
  ];

  programs.zathura = {
    enable = true;

    options = {
      recolor = true;
      selection-clipboard = "clipboard";
    };
  };

  xdg.mimeApps = {
    defaultApplications = let
      zathura = "org.pwmt.zathura.desktop";
    in {
      "application/epub+zip" = zathura;
      "application/pdf" = zathura;
    };

    enable = true;
  };
}
