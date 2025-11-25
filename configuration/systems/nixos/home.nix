{pkgs, ...}: {
  dconf.settings = {
    "org/nemo/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = true;
    };
  };

  gtk = let
    gnomeTheme = pkgs.gnome-themes-extra;
  in {
    enable = true;

    iconTheme = {
      name = "Adwaita";
      package = gnomeTheme;
    };
  };

  home = {
    packages = with pkgs; [
      equibop
      libnotify
      maestral
      nemo-with-extensions
      vlc
      wev
      wl-clipboard
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
  };

  imports = [
    ../linux/home.nix
    ../../modules/clipboard
    ../../modules/hypr
    ../../modules/rofi
    ../../modules/swaync
    ../../modules/waybar
  ];

  services.udiskie = {
    enable = true;

    settings.program_options.file_manager = "${
      pkgs.nemo-with-extensions
    }/bin/nemo";
  };

  stylix.targets.waybar.font = "sansSerif";

  xdg = {
    configFile."mimeapps.list".force = true;

    desktopEntries.nemo = {
      exec = "${pkgs.nemo-with-extensions}/bin/nemo";
      name = "Files";
    };

    mimeApps = {
      defaultApplications = {
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "application/x-gnome-saved-search" = ["nemo.desktop"];
        "inode/directory" = ["nemo.desktop"];
      };

      enable = true;
    };
  };
}
