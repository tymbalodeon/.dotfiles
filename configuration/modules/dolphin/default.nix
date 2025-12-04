{pkgs, ...}: {
  # TODO: update for dolphin
  # dconf.settings = {
  #   "org/nemo/preferences" = {
  #     default-folder-viewer = "list-view";
  #     show-hidden-files = true;
  #   };
  # };

  home.packages = with pkgs.kdePackages; [
    dolphin
    qtsvg
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
