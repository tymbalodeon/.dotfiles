{pkgs, ...}: {
  home = {
    file = {
      ".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;
      ".config/hypr/wallpaper".source = ./hypr/wallpaper;
      ".config/jj/config.toml".source = ../../jj/config.toml;
      ".config/rofi/config.rasi".source = ./rofi/config.rasi;
      ".config/swaync/style.css".source = ./swaync/style.css;
      ".config/tinty/rofi.toml".source = ./tinty/rofi.toml;
      ".config/tinty/waybar.toml".source = ./tinty/waybar.toml;
      ".config/waybar/colors.css".source = ./waybar/colors.css;
      ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
      ".config/waybar/style.css".source = ./waybar/style.css;
      ".rustup/settings.toml".source = ./rustup/settings.toml;
    };

    packages = with pkgs; [
      brightnessctl
      equibop
      gforth
      rofi-wayland
      waybar
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

  imports = [../linux/home.nix];

  programs = {
    ghostty.settings = {
      font-size = 8;
      window-decoration = false;
    };

    kitty.settings.font_size = 8;
  };

  services.swaync.enable = true;
}
