{pkgs, ...}: {
  dconf.settings = {
    "org/nemo/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = true;
    };
  };

  home.packages = [pkgs.nemo-with-extensions];

  services.udiskie = {
    enable = true;

    settings.program_options.file_manager = "${
      pkgs.nemo-with-extensions
    }/bin/nemo";
  };

  xdg = {
    configFile."mimeapps.list".force = true;

    desktopEntries.nemo = {
      exec = "${pkgs.nemo-with-extensions}/bin/nemo";
      name = "Files";
    };

    mimeApps = {
      defaultApplications = {
        "application/x-gnome-saved-search" = ["nemo.desktop"];
        "inode/directory" = ["nemo.desktop"];
      };

      enable = true;
    };
  };
}
