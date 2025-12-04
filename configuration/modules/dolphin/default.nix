{pkgs, ...}: {
  # TODO: update for dolphin
  # dconf.settings = {
  #   "org/nemo/preferences" = {
  #     default-folder-viewer = "list-view";
  #     show-hidden-files = true;
  #   };
  # };

  home.packages = with pkgs; [
    # kdePackages.qtsvg
    # kdePackages.kio
    kdePackages.dolphin
    # kdePackages.kdegraphics-thumbnailers
    # taglib
  ];

  services.udiskie = {
    enable = true;

    settings.program_options.file_manager = "${
      pkgs.kdePackages.dolphin
    }/bin/dolphin";
  };

  xdg = {
    configFile."mimeapps.list".force = true;

    desktopEntries.dolphin = {
      exec = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      name = "Files";
    };

    mimeApps = {
      defaultApplications = {
        "application/x-gnome-saved-search" = ["dolphin.desktop"];
        "inode/directory" = ["dolphin.desktop"];
      };

      enable = true;
    };
  };
}
