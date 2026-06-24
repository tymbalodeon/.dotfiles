{
  lib,
  pkgs,
  ...
}: {
  dconf = {
    enable = true;
    settings."org/gnome/nautilus/preferences".default-folder-viewer = "list-view";
  };

  home.packages = [pkgs.nautilus];

  services.udiskie = {
    enable = true;
    settings.program_options.file_manager = "${lib.getExe pkgs.nautilus}";
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
