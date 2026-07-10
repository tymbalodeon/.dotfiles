{
  config,
  pkgs,
  ...
}: let
  cursorTheme = "Bibata-Modern-Classic";
in {
  browser.enable = true;

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
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home = {
    packages = with pkgs; [
      equibop
      libnotify
      wev
    ];

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      name = cursorTheme;
      package = pkgs.bibata-cursors;
      size = 16;
      x11.enable = true;
    };
  };

  imports = [
    ../bar
    ../bluetooth
    ../browser
    ../clipboard
    ../cursor
    ../dictionary
    ../mail
    ../monitors
    ../notifications
    ../reaper
    # TODO: figure out how to include this on linux.nix without pulling in browser
    ../rss
    ../theme
    ../vpn
    ../window-manager
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
