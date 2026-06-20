{
  config,
  pkgs,
  ...
}: let
  cursorTheme = "Bibata-Modern-Classic";
in {
  gtk = {
    enable = true;

    cursorTheme = {
      name = cursorTheme;
      package = pkgs.bibata-cursors;
      size = config.cursor.size;
    };

    gtk3.extraConfig."gtk-cursor-theme-name" = cursorTheme;
    gtk4.extraConfig.Settings = cursorTheme;

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
  };

  home = {
    packages = with pkgs; [
      equibop
      libnotify
      wev
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = cursorTheme;
      size = 16;
      x11.enable = true;
    };
  };

  imports = [
    ../bluetooth
    ../browser
    ../clipboard
    ../cursor
    ../dictionary
    ../linux
    ../mail
    ../monitors
    ../niri
    ../reaper
    ../stylix
    ../swaync
    ../waybar
  ];

  stylix.targets.waybar.font = "sansSerif";

  xdg = {
    configFile."mimeapps.list".force = true;
    enable = true;

    mimeApps = {
      defaultApplications."application/pdf" = ["org.pwmt.zathura.desktop"];
      enable = true;
    };
  };
}
