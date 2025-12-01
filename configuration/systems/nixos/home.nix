{pkgs, ...}: {
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
      mpv
      vlc
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

  imports = [
    ../linux/home.nix
    ../../modules/clipboard
    ../../modules/hyprland
    ../../modules/nemo
    ../../modules/niri
    ../../modules/reaper
    ../../modules/swaync
    ../../modules/waybar
  ];

  stylix.targets.waybar.font = "sansSerif";

  xdg = {
    configFile."mimeapps.list".force = true;

    mimeApps = {
      defaultApplications."application/pdf" = ["org.pwmt.zathura.desktop"];
      enable = true;
    };
  };
}
