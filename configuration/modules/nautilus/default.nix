{pkgs, ...}: {
  services.udiskie = {
    enable = true;

    settings.program_options.file_manager = "${
      pkgs.nautilus
    }/bin/nautilus";
  };

  xdg = {
    configFile."mimeapps.list".force = true;

    mimeApps = {
      defaultApplications = {
        "application/x-gnome-saved-search" = ["org.gnome.Nautilus.desktop"];
        "inode/directory" = ["org.gnome.Nautilus.desktop"];
      };

      enable = true;
    };
  };
}
