{pkgs, ...}: {
  dconf.settings = {
    "org/nemo/preferences" = {
      default-folder-viewer = "list-view";
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

    theme = {
      name = "Adwaita-dark";
      package = gnomeTheme;
    };
  };

  home = {
    packages = with pkgs; [
      brightnessctl
      equibop
      hyprlock
      hyprpicker
      nemo
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
    ../../modules/hypr
    ../../modules/rofi
    ../../modules/swaync
    ../../modules/waybar
  ];

  programs.kitty.font.size = 8;

  services.udiskie = {
    enable = true;

    settings.program_options.file_manager = "${
      pkgs.nemo-with-extensions
    }/bin/nemo";
  };
}
