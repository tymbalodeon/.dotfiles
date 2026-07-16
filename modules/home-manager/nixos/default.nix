{
  config,
  pkgs,
  ...
}: let
  inherit (config.stylix) cursor;
in {
  browser.enable = true;

  gtk = {
    enable = true;
    cursorTheme = cursor;
    gtk3.extraConfig."gtk-cursor-theme-name" = cursor.name;
    gtk4.extraConfig.Settings = cursor.name;

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
      x11.enable = true;
    };
  };

  imports = [
    ../audio
    ../bar
    ../bluetooth
    ../browser
    ../clipboard
    ../dictionary
    ../mail
    ../monitors
    ../notifications
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
