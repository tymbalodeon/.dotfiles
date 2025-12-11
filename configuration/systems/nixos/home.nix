{
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
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
        wev
        wordbook
      ];

      pointerCursor = {
        gtk.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };
    };

    stylix.targets.waybar.font = "sansSerif";

    xdg = {
      configFile."mimeapps.list".force = true;
      enable = true;

      mimeApps = {
        defaultApplications."application/pdf" = ["org.pwmt.zathura.desktop"];
        enable = true;
      };
    };
  };

  imports = [
    ../linux/home.nix
    ../../modules/clipboard
    ../../modules/monitors
    ../../modules/niri
    ../../modules/reaper
    ../../modules/swaync
    ../../modules/waybar
  ];

  options.laptop = mkOption {
    default = false;
    type = types.bool;
  };
}
