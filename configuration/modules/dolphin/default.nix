{pkgs, ...}: {
  home.packages = with pkgs; [
    icoutils
    kdePackages.dolphin
    kdePackages.ffmpegthumbs
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kdesdk-thumbnailers
    kdePackages.kimageformats
    kdePackages.qtsvg
    libappimage
    resvg
    taglib
  ];

  services.udiskie = {
    enable = true;

    settings.program_options.file_manager = "${
      pkgs.kdePackages.dolphin
    }/bin/dolphin";
  };

  xdg = {
    configFile."mimeapps.list".force = true;

    mimeApps = {
      defaultApplications = {
        "application/x-gnome-saved-search" = ["dolphin.desktop"];
        "inode/directory" = ["dolphin.desktop"];
      };

      enable = true;
    };
  };
}
