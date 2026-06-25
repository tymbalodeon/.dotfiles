{
  lib,
  pkgs,
  ...
}: {
  dconf = {
    enable = true;

    settings = let
      defaultColumns = ["name" "type" "size" "date_created" "date_modified"];
    in {
      "org/gnome/nautilus/icon-view".default-zoom-level = "small";

      "org/gnome/nautilus/list-view" = {
        default-column-order = defaultColumns;
        default-visible-columns = defaultColumns;
        default-zoom-level = "small";
        use-tree-view = true;
      };

      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-delete-permanently = true;
      };
    };
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
